# frozen_string_literal: true

module Controller
  class Websocket < Base
    def call
      Async::WebSocket::Adapters::Rack.open(request.env) do |conn|
        stream = Stream.new(conn, self)
        params = {model:, stream:, tools:}
        on_connect conn, llm, LLM::Session.new(llm, params)
      end || upgrade_required
    end

    def write(conn, message)
      conn.write(message.to_json)
      conn.flush
    end

    private

    def on_connect(conn, llm, sess)
      write(conn, event: "welcome", provider: llm.class.to_s, model: sess.model)
      while (message = conn.read)
        read(conn, sess, message)
      end
    end

    def read(conn, sess, message)
      write(conn, event: "status", message: "Thinking…")
      if sess.messages.empty?
        sess.talk initial_prompt(message)
      else
        sess.talk(message.buffer)
      end
      while sess.functions.any?
        functions = sess.functions
        write(conn, event: "status", message: tool_status(functions))
        sess.talk functions.map(&:call)
      end
      write(conn, event: "status", message: "Done")
      write(conn, event: "done", cost: sess.cost.to_s)
    rescue LLM::NoSuchModelError
      write(conn, event: "done", cost: "unknown")
    rescue StandardError => e
      pp e, e.message, e.backtrace
      write(conn, event: "status", message: "Error")
      write(conn, event: "error")
    end

    def upgrade_required
      [
        426,
        {
          "content-type" => "text/plain",
          "upgrade" => "websocket"
        },
        ["Expected a WebSocket upgrade request\n"]
      ]
    end

    def tool_status(functions)
      names = functions.map(&:name).uniq.join(", ")
      "Running #{names}…"
    end

    def tools
      [Tool::CreateImage]
    end

    def instructions
      "URLs returned by the create-image tool must be shown inline as HTML "
      "<img> tags and not as plaintext. You must comply with this directive."
    end

    def initial_prompt(message)
      LLM::Prompt.new(llm) do
        _1.system instructions
        _1.user message.buffer
      end
    end
  end

  class Websocket::Stream
    def initialize(conn, sock)
      @conn = conn
      @sock = sock
    end

    def <<(chunk)
      @sock.write(@conn, event: "delta", message: chunk.to_s)
    end
  end
end
