# frozen_string_literal: true

module Relay
  class Router < Roda
    include Relay::Concerns::Attachment
    include Relay::Concerns::Context
    include Relay::Concerns::View

    ##
    # Plugins
    plugin :common_logger

    plugin :sessions,
      key: "relay.session",
      secret: ENV["SESSION_SECRET"]

    plugin :partials,
      assume_fixed_locals: Relay.production?,
      check_template_mtime: !Relay.production?,
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

      r.is "mcps" do
        r.get do
          Routes::ListMCP.new(self).call
        end

        r.post do
          Routes::MCP::Create.new(self).call
        end
      end

      r.is "mcps", "new" do
        r.get do
          Routes::MCP::New.new(self).call
        end
      end

      r.is "mcps", "form" do
        r.post do
          Routes::MCP::Form.new(self).call
        end
      end

      r.on "mcps", Integer do |id|
        r.get do
          Routes::MCP::Show.new(self).call(id)
        end

        r.is "toggle" do
          r.post do
            Routes::MCP::Toggle.new(self).call(id)
          end
        end

        r.is "delete" do
          r.post do
            Routes::MCP::Delete.new(self).call(id)
          end
        end

        r.post do
          Routes::MCP::Update.new(self).call(id)
        end
      end

      r.on "settings" do
        r.is "set-model" do
          Routes::Settings::SetModel.new(self).call
        end

        r.is "set-context" do
          Routes::Settings::SetContext.new(self).call
        end

        r.is "new-context" do
          Routes::Settings::NewContext.new(self).call
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

      r.is "controls" do
        r.get do
          Routes::ListControls.new(self).call
        end
      end

      r.is "chat" do
        r.get do
          Routes::ListChat.new(self).call
        end
      end

      r.is "contexts" do
        r.get do
          Routes::ListContexts.new(self).call
        end
      end

      r.is "tools" do
        r.get do
          Routes::ListTools.new(self).call
        end
      end

      r.is "upload-attachment" do
        r.post do
          Routes::UploadAttachment.new(self).call
        end
      end

      r.is "clear-attachment" do
        r.post do
          Routes::ClearAttachment.new(self).call
        end
      end

    end

  end
end
