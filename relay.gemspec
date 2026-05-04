# frozen_string_literal: true

require_relative "lib/relay/version"

Gem::Specification.new do |spec|
  spec.name = "relay"
  spec.version = Relay::VERSION
  spec.authors = ["Antar Azri", "0x1eef"]
  spec.email = ["azantar@proton.me", "0x1eef@hardenedbsd.org"]
  spec.summary = "Self-hosted LLM workspace built on llm.rb"
  spec.description = "Relay is a production-style, self-hostable LLM environment built on llm.rb."
  spec.homepage = "https://github.com/llmrb/relay"
  spec.license = "0BSD"
  spec.required_ruby_version = ">= 3.3"
  spec.bindir = "bin"
  spec.executables = ["relay"]

  spec.files = Dir[
    "app/**/*",
    "bin/*",
    "db/**/*",
    "lib/**/*",
    "libexec/**/*",
    "public/images/**/*",
    "public/js/**/*",
    "public/stylesheets/**/*",
    "resources/**/*",
    "tasks/**/*",
    "test/**/*",
    "Gemfile",
    "LICENSE",
    "README.md",
    "Rakefile",
    "config.ru",
    "public/.gitkeep"
  ].select { File.file?(_1) }
  spec.require_paths = ["lib"]

  spec.add_dependency "async-websocket"
  spec.add_dependency "bcrypt"
  spec.add_dependency "erubi"
  spec.add_dependency "erb"
  spec.add_dependency "falcon"
  spec.add_dependency "llm.rb", "~> 8.0"
  spec.add_dependency "net-http-persistent"
  spec.add_dependency "rack"
  spec.add_dependency "rackup"
  spec.add_dependency "redcarpet"
  spec.add_dependency "roda"
  spec.add_dependency "sequel"
  spec.add_dependency "sqlite3"
  spec.add_dependency "test-cmd.rb"
  spec.add_dependency "tilt"
  spec.add_dependency "xchan.rb"
  spec.add_dependency "zeitwerk"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "test-unit"
end
