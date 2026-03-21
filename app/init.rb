# frozen_string_literal: true

module Relay
  require "bundler/setup"
  Bundler.require(:default)

  require "erb"
  require "yaml"


  loader = Zeitwerk::Loader.new
  loader.ignore(
    File.join(__dir__, "init.rb"),
    File.join(__dir__, "init")
  )
  loader.push_dir(__dir__, namespace: self)
  loader.setup

  ##
  # Returns the path to the public/ directory
  # @return [String]
  def self.public_dir
    @public_dir ||= File.realpath File.join(__dir__, "..", "public")
  end

  require_relative "init/database"
  require_relative "init/sidekiq"
  require_relative "init/router"
end
