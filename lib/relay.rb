# frozen_string_literal: true

module Relay
  require "test-cmd"
  require_relative "relay/cache"
  require_relative "relay/attachment"
  require_relative "relay/jukebox"
  require_relative "relay/markdown"
  require_relative "relay/model_info/sync"
  require_relative "relay/theme"
  require_relative "relay/task_monitor"
  require_relative "relay/task"
  require_relative "relay/tool"
  require_relative "relay/model"
  require_relative "relay/reloader"

  ##
  # Returns the current Rack environment
  # @return [String]
  def self.environment
    ENV["RACK_ENV"] || "development"
  end

  ##
  # Returns true when running in development
  # @return [Boolean]
  def self.development?
    environment == "development"
  end

  ##
  # Returns true when running in production
  # @return [Boolean]
  def self.production?
    environment == "production"
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

  ##
  # @return [String]
  def self.logs_dir
    @logs_dir ||= File.join(root, "tmp")
  end

  ##
  # Renders an erb template
  # @param [String] path
  # @param [Hash] locals
  # @return [String]
  def self.erb(path, locals = {})
    tmpl = File.read File.join(views_dir, path)
    ERB.new(tmpl).result_with_hash(locals)
  end

  ##
  # Reload Relay (useful in development enviroments)
  # @param [Boolean] reload
  # @return [Array<String>]
  def self.reload
    LLM::Tool.clear_registry!
    Relay.loader.reload
    Dir[File.join(tools_dir, "*.rb")].sort.each do |path|
      load(path)
    end
  end
end
