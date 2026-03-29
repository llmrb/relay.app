# frozen_string_literal: true

module Relay::Routes
  class Websocket < Base
    require_relative "websocket/connection"
    require_relative "websocket/stream"

    prepend Relay::Hooks::RequireUser

    include Connection
    include Relay::Tools

    def call
      Async::WebSocket::Adapters::Rack.open(request.env) do |conn|
        mcps.each(&:start)
        stream = Stream.new(conn, self)
        params = { model:, stream:, tools: }
        on_connect conn, llm, ctx, params
      ensure
        mcps.each(&:stop)
      end || upgrade_required
    end

    private

    ##
    # Returns an array of MCP clients that can provide tools
    # @return [Array<LLM::MCP>]
    def mcps
      @mcps ||= Relay.mcp.stdio.map { LLM.mcp(stdio: _1.config) }
    end

    ##
    # Returns an array of tools
    # @return [Array<LLM::Tool>]
    def tools
      [*LLM::Tool.registry, *mcps.flat_map(&:tools)]
    end

    def upgrade_required
      response.status = 426
      response["content-type"] = "text/plain"
      response["upgrade"] = "websocket"
      "Expected a WebSocket upgrade request\n"
    end

    def tool_status(functions)
      names = functions.filter_map(&:name).reject(&:empty?).uniq
      return "Running tools…" if names.empty?
      "Running #{names.join(', ')}…"
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
