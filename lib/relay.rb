# frozen_string_literal: true

require "llm"
require "fileutils"

module Relay
  DEFAULT_HOME = File.expand_path(ENV.fetch("RELAY_HOME", "~/.config/relay"))

  def self.home
    @home ||= DEFAULT_HOME
  end

  def self.home=(path)
    @home = path
  end

  def self.root
    File.dirname(__dir__)
  end

  def self.env
    @env ||= {
      "RELAY_HOME" => home,
      "RELAY_DB" => File.join(home, "relay.db"),
      "RELAY_SESSION_SECRET" => "",
      "RACK_ENV" => "production"
    }
  end

  def self.setup!
    FileUtils.mkdir_p(home)
    FileUtils.mkdir_p(File.join(home, "tools"))
    FileUtils.mkdir_p(File.join(home, "db"))
  end
end
