# frozen_string_literal: true

module Relay
  require_relative "relay/cache"
  require_relative "relay/markdown"
  require_relative "relay/task_monitor"
  require_relative "relay/task"
  require_relative "relay/model"
  require_relative "relay/reloader"

  ##
  # Returns the current Rack environment
  # @return [String]
  def self.environment
    ENV.fetch("RACK_ENV", "development")
  end

  ##
  # Returns true when running in development
  # @return [Boolean]
  def self.development?
    environment == "development"
  end

  ##
  # Returns mcp configuration
  # @return [LLM::Object]
  def self.mcp
    path = File.join(config_dir, "mcp.yml")
    @mcp ||= if File.readable?(path)
      LLM::Object.from YAML.safe_load_file(path)
    else
      LLM::Object.from(stdio: [])
    end
  end

  ##
  # Returns an object that can be used to store application state
  # that should persist between requests.
  # @return [Relay::InMemoryCache]
  def self.cache
    @cache
  end
  @cache = Cache::InMemoryCache.new

  ##
  # Returns the root path of the application
  # @return [String]
  def self.root
    @root ||= File.realpath File.join(__dir__, "..")
  end

  ##
  # @return [Array<String>]
  #  Returns the tools directory
  def self.tools_dir
    @tools_dir ||= File.join(root, "app", "tools")
  end

  ##
  # Returns the path to the public/ directory
  # @return [String]
  def self.public_dir
    @public_dir ||= File.join(root, "public")
  end

  ##
  # Returns the path to the app/assets/ directory
  # @return [String]
  def self.assets_dir
    @assets_dir ||= File.join(root, "app", "assets")
  end

  ##
  # @return [String]
  # Returns the path to the app/views/resources directory
  def self.resources_dir
    @resources_dir ||= File.join(root, "app", "resources")
  end

  ##
  # Returns the path to the app/views/ directory
  # @return [String]
  def self.views_dir
    @views_dir ||= File.join(root, "app", "views")
  end

  ##
  # Returns the path to the app/config directory
  # @return [String]
  def self.config_dir
    @config_dir ||= File.join(root, "app", "config")
  end

  ##
  # Returns the path to the db/migrate directory
  # @return [String]
  def self.migrations_dir
    @migrations_dir ||= File.join(root, "db", "migrate")
  end

  ##
  # Returns the path to the app/views/fragments directory
  # @return [String]
  def self.fragments_dir
    @fragments_dir ||= File.join(views_dir, "fragments")
  end
end
