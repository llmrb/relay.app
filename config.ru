# frozen_string_literal: true

require "bundler/setup"
Bundler.require(:default)

require "active_record"
require "erb"
require "yaml"

require_relative "db/config"
DB.establish_connection!(env: ENV["RACK_ENV"] || "development")

require File.join(__dir__, "app", "server", "tools", "init.rb")
require File.join(__dir__, "app", "server", "models", "init.rb")
require File.join(__dir__, "app", "server", "routes", "init.rb")
require File.join(__dir__, "app", "server", "router.rb")

use Rack::Static, urls: ["/g"], root: "public"
run Server::Router
