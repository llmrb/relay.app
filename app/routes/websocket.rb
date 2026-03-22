# frozen_string_literal: true

module Relay::Routes
  class Websocket < Base
    require_relative "websocket/connection"
    require_relative "websocket/stream"

    include Connection
    include Relay::Tools

    def call
      Async::WebSocket::Adapters::Rack.open(request.env) do |conn|
        stream = Stream.new(conn, self)
        params = { model:, stream:, tools: }
        llm.tracer = logger(llm)
        on_connect conn, llm, LLM::Session.new(llm, params)
      end || upgrade_required
    end

    private

    def upgrade_required
      response.status = 426
      response["content-type"] = "text/plain"
      response["upgrade"] = "websocket"
      "Expected a WebSocket upgrade request\n"
    end

    def tool_status(functions)
      names = functions.map(&:name).uniq.join(", ")
      "Running #{names}…"
    end

    def tools
      [CreateImage, RelayKnowledge, JukeBox]
    end

    def instructions
      File.read File.join(root, "app", "prompts", "system.md")
    end

    def initial_prompt(message)
      LLM::Prompt.new(llm) do
        _1.system instructions
        _1.user message
      end
    end

    ##
    # Returns a logging tracer
    # @return [LLM::Tracer]
    def logger(llm)
      filename = format("%s-%s.log", llm.name, Date.today.strftime("%Y-%m-%d"))
      LLM::Tracer::Logger.new(llm, path: File.join(root, "tmp", filename))
    end
  end
end
