# frozen_string_literal: true

require "llm"
require "fileutils"
require "shellwords"

module Relay
  HOME = ENV.fetch("RELAY_HOME", File.expand_path("~/.config/relay"))
end
