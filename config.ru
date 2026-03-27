# frozen_string_literal: true

require_relative "app/init"

if Relay.development?
  use Rack::Reloader
  use Rack::Lint
  use Rack::TempfileReaper
  use Rack::ContentLength
  use Rack::ETag
  use Rack::ConditionalGet
  use Rack::Head

  use Rack::Builder.new {
    use Rack::Config do
      Relay.loader.reload
    end

    run ->(env) { @app.call(env) }
  }
end

map "/sidekiq" do
  run Sidekiq::Web
end

use Rack::Static, urls: ["/g", "/images", "/stylesheets", "/js"], root: "public"
run Relay::Router
