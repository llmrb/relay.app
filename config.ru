# frozen_string_literal: true

require_relative "app/init"

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
  map("/sidekiq") { run Sidekiq::Web }
end

use Rack::Static, urls: ["/g", "/images", "/stylesheets", "/js"], root: "public"
run Relay::Router
