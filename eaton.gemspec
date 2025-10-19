# frozen_string_literal: true

require_relative "lib/eaton/version"

Gem::Specification.new do |spec|
  spec.name = "eaton"
  spec.version = Eaton::VERSION
  spec.authors = ["Jonathan Siegel"]
  spec.email = ["jonathan@example.com"]

  spec.summary = "Ruby gem and CLI for managing Eaton Rack PDU G4 devices via REST API"
  spec.description = "Comprehensive power monitoring and management for Eaton Rack PDU G4 devices. Features include overall power consumption, per-outlet monitoring, branch distribution, detailed metrics (voltage, current, power factor), OAuth2 authentication, and SSH tunneling support."
  spec.homepage = "https://github.com/usiegj00/eaton"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/usiegj00/eaton"
  spec.metadata["bug_tracker_uri"] = "https://github.com/usiegj00/eaton/issues"
  spec.metadata["changelog_uri"] = "https://github.com/usiegj00/eaton/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://github.com/usiegj00/eaton"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "thor", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
