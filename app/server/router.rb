# frozen_string_literal: true

class Server::Router < Roda
  include Server::Routes

  route do |r|
    r.is "models" do
      r.get do
        ListModels.new(self).call
      end
    end

    r.is "ws" do
      throw :halt, Websocket.new(self).call
    end

    [404, {"content-type" => "text/plain"}, ["Not Found\n"]]
  end
end
