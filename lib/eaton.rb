# frozen_string_literal: true

require_relative "eaton/version"
require_relative "eaton/client"
require_relative "eaton/power"
require_relative "eaton/cli"

module Eaton
  class Error < StandardError; end
end
