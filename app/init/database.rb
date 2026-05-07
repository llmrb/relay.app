# frozen_string_literal: true

module Relay::Database
  extend self

  ##
  # Loads the database config for the given environment.
  # @param [String] env
  # @return [Hash]
  def load(env:)
    erb = ERB.new(File.read(File.join(Relay.home, "db", "config.yml")))
    config = YAML.safe_load(erb.result, aliases: true)
    config.fetch(env)
  end

  ##
  # Establishes a Sequel connection for the configured environment.
  # @param [String] env
  # @return [Sequel::Database]
  def connect!(env:)
    settings = load(env:)
    adapter = settings.fetch("adapter")
    database = settings.fetch("database")
    adapter = "sqlite" if adapter == "sqlite3"
    database = File.expand_path(database, Relay.home) unless database.start_with?("/")
    Sequel.connect(
      adapter:,
      database:,
      max_connections: settings.fetch("pool", 5),
      pool_timeout: settings.fetch("timeout", 5000) / 1000.0
    )
  end
end

Relay::DB = Relay::Database.connect!(env: Relay.environment)
Sequel::Model.db = Relay::DB
