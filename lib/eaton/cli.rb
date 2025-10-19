# frozen_string_literal: true

require "thor"
require "json"

module Eaton
  class CLI < Thor
    class_option :host, type: :string, required: true, desc: "PDU hostname or IP address"
    class_option :port, type: :numeric, default: 443, desc: "PDU port (default: 443)"
    class_option :username, type: :string, required: true, desc: "PDU username"
    class_option :password, type: :string, required: true, desc: "PDU password"
    class_option :verify_ssl, type: :boolean, default: false, desc: "Verify SSL certificates"
    class_option :host_header, type: :string, desc: "Custom Host header (for SSH tunneling)"
    class_option :format, type: :string, default: "text", enum: ["text", "json"], desc: "Output format"

    desc "power", "Get overall power consumption in watts"
    def power
      with_client do |client|
        power = client.power
        output_result("Overall Power", { watts: power })
      end
    end

    desc "outlets", "Get per-outlet power consumption"
    def outlets
      with_client do |client|
        outlets = client.outlets
        # Filter out zero-power outlets in text mode
        if options[:format] == "text"
          outlets = outlets.select { |o| o[:watts] && o[:watts] > 0 }
        end
        output_result("Outlet Power", outlets)
      end
    end

    desc "detailed", "Get detailed power information"
    def detailed
      with_client do |client|
        info = client.detailed
        # Filter outlets in text mode
        if options[:format] == "text" && info[:outlets]
          info[:outlets] = info[:outlets].select { |o| o[:watts] && o[:watts] > 0 }
        end
        output_result("Detailed Power Information", info)
      end
    end

    desc "branches", "Get power consumption per branch"
    def branches
      with_client do |client|
        branches = client.branches
        # Filter out zero-current branches in text mode
        if options[:format] == "text"
          branches = branches.select { |b| b[:current] && b[:current] > 0 }
        end
        output_result("Branch Power", branches)
      end
    end

    desc "info", "Display PDU device information"
    def info
      with_client do |client|
        info = client.info
        output_result("PDU Device Information", info)
      end
    end

    desc "auth", "Test authentication with the PDU"
    def auth
      with_client do |client|
        token = client.authenticate!
        output_result("Authentication Test", {
          status: "success",
          token_present: !token.nil?,
          token_length: token&.length
        })
      end
    end

    no_commands do
      def with_client
        client = Client.new(
          host: options[:host],
          port: options[:port],
          username: options[:username],
          password: options[:password],
          verify_ssl: options[:verify_ssl],
          host_header: options[:host_header]
        )

        yield client
      rescue Client::AuthenticationError => e
        error("Authentication failed: #{e.message}")
      rescue Client::APIError => e
        error("API error: #{e.message}")
      rescue StandardError => e
        error("Unexpected error: #{e.message}")
      ensure
        client&.logout
      end

      def output_result(title, data)
        if options[:format] == "json"
          puts JSON.pretty_generate(data)
        else
          output_text(title, data)
        end
      end

      def output_text(title, data)
        puts "\n#{title}:"
        puts "=" * 60

        case data
        when Hash
          output_hash(data)
        when Array
          data.each_with_index do |item, index|
            puts "\n[#{index + 1}]"
            output_hash(item) if item.is_a?(Hash)
          end
        else
          puts data
        end

        puts
      end

      def output_hash(hash, indent = 0)
        hash.each do |key, value|
          prefix = "  " * indent
          case value
          when Hash
            puts "#{prefix}#{key}:"
            output_hash(value, indent + 1)
          when Array
            puts "#{prefix}#{key}:"
            value.each_with_index do |item, index|
              if item.is_a?(Hash)
                puts "#{prefix}  [#{index}]:"
                output_hash(item, indent + 2)
              else
                puts "#{prefix}  - #{item}"
              end
            end
          else
            puts "#{prefix}#{key}: #{value}"
          end
        end
      end

      def error(message)
        STDERR.puts "ERROR: #{message}"
        exit 1
      end
    end
  end
end
