# frozen_string_literal: true

module Relay
  require_relative "relay/version"
  require_relative "relay/cache"
  require_relative "relay/attachment"
  require_relative "relay/jukebox"
  require_relative "relay/markdown"
  require_relative "relay/theme"
  require_relative "relay/task_monitor"
  require_relative "relay/task"
  require_relative "relay/tool"
  require_relative "relay/model"
  require_relative "relay/reloader"

  PROVIDERS = {
    "anthropic" => -> { LLM.anthropic(key: ENV["ANTHROPIC_SECRET"]) },
    "deepseek" => -> { LLM.deepseek(key: ENV["DEEPSEEK_SECRET"]) },
    "google" => -> { LLM.google(key: ENV["GOOGLE_SECRET"]) },
    "openai" => -> { LLM.openai(key: ENV["OPENAI_SECRET"]) },
    "xai" => -> { LLM.xai(key: ENV["XAI_SECRET"]) }
  }.freeze
  private_constant :PROVIDERS

  ##
  # @return [String]
  def self.banner
    " ____      _             \n" \
    "|  _ \\ ___| | __ _ _   _ \n" \
    "| |_) / _ \\ |/ _` | | | |\n" \
    "|  _ <  __/ | (_| | |_| |\n" \
    "|_| \\_\\___|_|\\__,_|\\__, |\n" \
    "                   |___/ \n\n"
  end

  ##
  # Returns all known providers
  # @return [LLM::Object]
  def self.providers
    @providers ||= LLM::Object.from(PROVIDERS)
  end

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
  # Returns the writable Relay home directory
  # @return [String]
  def self.home
    @home ||= ENV["RELAY_HOME"] || File.join(Dir.home, ".relay")
  end

  ##
  # Returns the path to the Relay env file
  # @return [String]
  def self.env_path
    @env_path ||= File.join(home, "env")
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
  # Returns the path to generated images
  # @return [String]
  def self.images_dir
    @images_dir ||= File.join(home, "g")
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
    @logs_dir ||= File.join(home, "tmp")
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
    paths = Dir[File.join(tools_dir, "*.rb")]
    paths.concat Dir[File.join(home, "tools", "*.rb")]
    paths.sort.each do
      load(_1)
    rescue => ex
      warn "tool error\n"
            "#{ex.class}: #{ex.message}\n"
            "#{ex.backtrace.join("\n")}"
    end
  end
end
