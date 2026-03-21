# frozen_string_literal: true

class Server::Router < Roda
  ##
  # Plugins
  plugin :common_logger
  plugin :partials,
    escape: true,
    layout: "layout",
    views: File.expand_path("views", __dir__)

  ##
  # Routes
  route do |r|
    r.on "api" do
      r.is "models" do
        r.get do
          ListModels.new(self).call
        end
      end

      r.is "tools" do
        r.get do
          ListTools.new(self).call
        end
      end

      r.is "ws" do
        throw :halt, Websocket.new(self).call
      end
    end

    r.root do
      response['content-type'] = "text/html; charset=utf-8"
      page("chat", title: "Relay")
    end

    r.get true do
      r.redirect "/"
    end
  end

  private
  include Server::Routes
  def page(name, **locals)
    view(File.join("pages", name), layout_opts: {locals:})
  end
end
