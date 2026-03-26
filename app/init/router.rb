# frozen_string_literal: true

module Relay
  class Router < Roda
    ##
    # Plugins
    plugin :common_logger

    plugin :sessions,
      key: 'relay.session',
      secret: ENV["SESSION_SECRET"]

    plugin :partials,
      escape: true,
      layout: "layout",
      views: File.expand_path("../views", __dir__)

    ##
    # Routes
    route do |r|
      r.root do
        Pages::Chat.new(self).call
      end

      r.is "sign-in" do
        r.get do
          Pages::SignIn.new(self).call
        end

        r.post do
          Routes::SignIn.new(self).call
        end
      end

      r.get true do
        r.redirect "/"
      end

      r.on "settings" do
        r.is "set-model" do
          Routes::Settings::SetModel.new(self).call
        end

        r.is "set-provider" do
          Routes::Settings::SetProvider.new(self).call
        end
      end

      r.on "api" do
        r.is "ws" do
          throw :halt, Routes::Websocket.new(self).call
        end
      end

      r.is "models" do
        r.get do
          Routes::ListModels.new(self).call
        end
      end

      r.is "providers" do
        r.get do
          Routes::ListProviders.new(self).call
        end
      end

      r.is "tools" do
        r.get do
          Routes::ListTools.new(self).call
        end
      end
    end
  end
end
