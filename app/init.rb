# frozen_string_literal: true

module Relay
  require "async"
  require "async/websocket"
  require "async/websocket/adapters/rack"
  require "llm"
  require "roda"
  require "bcrypt"
  require "test-cmd"
  require "erb"
  require "zeitwerk"
  require "sequel"
  require "yaml"
  require "relay"

  loader = Zeitwerk::Loader.new
  loader.inflector.inflect(
    "github" => "GitHub",
    "list_mcp" => "ListMCP",
    "mcp" => "MCP"
  )
  loader.ignore(
    File.join(__dir__, "init.rb"),
    File.join(__dir__, "init")
  )
  loader.push_dir(__dir__, namespace: self)

  loader.enable_reloading if development?
  loader.setup

  ##
  # Returns the Zeitwerk loader used for application autoloading
  # @return [Zeitwerk::Loader]
  def self.loader
    @loader
  end
  @loader = loader

  FileUtils.mkdir_p Relay.home
  FileUtils.mkdir_p File.join(Relay.home, "db")
  FileUtils.mkdir_p Relay.images_dir
  FileUtils.mkdir_p Relay.logs_dir

  require_relative "init/env"
  require_relative "init/database"
  require_relative "init/router"

  Relay.reload
end
