# frozen_string_literal: true

require_relative "lib/relay/version"

Gem::Specification.new do |spec|
  spec.name = "relay.app"
  spec.version = Relay::VERSION
  spec.authors = ["Antar Azri", "0x1eef"]
  spec.email = ["azantar@proton.me", "0x1eef@hardenedbsd.org"]
  spec.summary = "Self-hostable LLM environment you can run in under 2 minutes"
  spec.description = "Relay is a self-hostable LLM environment built on llm.rb " \
    "that you can set up and get running in under 2 minutes. Extend it " \
    "with your own tools, connect MCP servers, and run an AI workspace " \
    "on your own infrastructure."
  spec.homepage = "https://github.com/llmrb/relay"
  spec.license = "0BSD"
  spec.required_ruby_version = ">= 3.3"
  spec.bindir = "bin"
  spec.executables = ["relay"]

  spec.files = Dir[
    "app/concerns/**/*",
    "app/config/**/*",
    "app/forms/**/*",
    "app/hooks/**/*",
    "app/init.rb",
    "app/init/**/*",
    "app/models/**/*",
    "app/pages/**/*",
    "app/prompts/**/*",
    "app/resources/**/*",
    "app/routes/**/*",
    "app/tools/**/*",
    "app/validators/**/*",
    "app/views/**/*",
    "bin/*",
    "db/config.yml",
    "db/migrate/**/*",
    "db/seeds.rb",
    "lib/**/*",
    "libexec/**/*",
    "public/images/relay.png",
    "public/js/relay.js",
    "public/js/relay.js.map",
    "public/stylesheets/application.css",
    "public/stylesheets/application.css.map",
    "CHANGELOG.md",
    "LICENSE",
    "README.md",
    "config.ru",
    "public/.gitkeep"
  ].select { File.file?(_1) }
  spec.require_paths = ["lib"]

  spec.add_dependency "async-websocket"
  spec.add_dependency "bcrypt"
  spec.add_dependency "erubi"
  spec.add_dependency "erb"
  spec.add_dependency "falcon"
  spec.add_dependency "llm.rb", "= 8.1.0"
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
  spec.add_dependency "logger"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "test-unit"
end
