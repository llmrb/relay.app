# frozen_string_literal: true

ENV["RACK_MULTIPART_BUFFERED_UPLOAD_BYTESIZE_LIMIT"] ||= (64 * 1024 * 1024).to_s

require_relative "app/init"

use Rack::Static, urls: ["/g"], root: Relay.public_dir
use Rack::Static, urls: ["/images", "/stylesheets", "/js"], root: Relay.public_dir
case Relay.environment
when "development"
  use Rack::Reloader
  use Rack::Lint
  use Rack::TempfileReaper
  use Rack::ContentLength
  use Rack::ETag
  use Rack::ConditionalGet
  use Rack::Head
  use Relay::Reloader
end

run Relay::Router
