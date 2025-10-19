# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "openssl"

module Eaton
  class Client
    class AuthenticationError < StandardError; end
    class APIError < StandardError; end

    include Power

    attr_reader :host, :username, :base_url

    def initialize(host:, username:, password:, port: 443, verify_ssl: false, host_header: nil)
      @host = host
      @username = username
      @password = password
      @port = port
      @verify_ssl = verify_ssl
      @host_header = host_header || host
      @base_path = "/rest/mbdetnrs/2.0"
      @token = nil
      @session = nil
    end

    def authenticate!
      request = Net::HTTP::Post.new("#{@base_path}/oauth2/token/")
      add_browser_headers(request)
      request.body = JSON.generate(username: @username, password: @password)

      response = execute_request(request)

      if response.code.to_i.between?(200, 299)
        data = JSON.parse(response.body)
        @token = data["access_token"]
        @session = data["session"]
        @token
      else
        raise AuthenticationError, "Authentication failed: #{response.body}"
      end
    rescue JSON::ParserError => e
      raise AuthenticationError, "Invalid response from server: #{e.message}"
    end

    def authenticated?
      !@token.nil?
    end

    def get(path)
      authenticate! unless authenticated?

      request = Net::HTTP::Get.new("#{@base_path}#{path}")
      add_auth_headers(request)

      handle_response(execute_request(request))
    end

    def post(path, data = {})
      authenticate! unless authenticated?

      request = Net::HTTP::Post.new("#{@base_path}#{path}")
      add_auth_headers(request)
      request.body = data.to_json

      handle_response(execute_request(request))
    end

    def logout
      return unless authenticated?

      begin
        delete(@session) if @session
      rescue APIError
        # Session might already be expired or deleted, ignore
      ensure
        @token = nil
        @session = nil
      end
    end

    private

    def http_connection
      @http_connection ||= begin
        http = Net::HTTP.new(@host, @port)
        http.use_ssl = true
        http.verify_mode = @verify_ssl ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
        http
      end
    end

    def execute_request(request)
      http_connection.request(request)
    end

    def add_browser_headers(request)
      request["Content-Type"] = "application/json"
      request["Host"] = @host_header
      request["Sec-Fetch-Mode"] = "cors"
      request["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36"
      request["Origin"] = "https://#{@host_header}"
      request["Sec-Fetch-Site"] = "same-origin"
    end

    def add_auth_headers(request)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@token}"
      request["Host"] = @host_header
    end

    def delete(path)
      request = Net::HTTP::Delete.new("#{@base_path}#{path}")
      add_auth_headers(request)

      handle_response(execute_request(request))
    end

    def handle_response(response)
      status_code = response.code.to_i

      case status_code
      when 200..299
        begin
          JSON.parse(response.body)
        rescue JSON::ParserError
          response.body
        end
      when 401, 403
        # Token might have expired, clear it and let caller retry
        @token = nil
        raise AuthenticationError, "Authentication failed or token expired"
      else
        error_message = begin
          data = JSON.parse(response.body)
          data["description"] || response.body
        rescue
          response.body
        end
        raise APIError, "API error (#{status_code}): #{error_message}"
      end
    end
  end
end
