# frozen_string_literal: true

class API::Websocket
  module Connection
    ##
    # Establishes the WebSocket connection and handles incoming messages
    # @param [Async::WebSocket::Adapters::Rack] conn
    #  The WebSocket connection object
    # @param [LLM::Provider] llm
    #  The selected LLM provider
    # @param [LLM::Session] sess
    #  The current LLM session
    # @return [void]
    def on_connect(conn, llm, sess)
      write(conn, event: "welcome", provider: llm.class.to_s, model: sess.model)
      while (message = conn.read)
        read(conn, sess, message)
      end
    end

    ##
    # Writes a message to the WebSocket connection
    # @param [Async::WebSocket::Adapters::Rack] conn
    #  The WebSocket connection object
    # @param [Hash] message
    #  The message to send, which will be converted to JSON
    # @return [void]
    def write(conn, message)
      conn.write(message.to_json)
      conn.flush
    end

    ##
    # Reads an incoming message, sends it to the LLM session, and handles any function calls
    # @param [Async::WebSocket::Adapters::Rack] conn
    #  The WebSocket connection object
    # @param [LLM::Session] sess
    #  The current LLM session
    # @param [String] message
    #  The incoming message
    # @return [void]
    def read(conn, sess, message)
      write(conn, event: "status", message: "Thinking…")
      send(sess, message)
      invoke(sess, sess.functions, conn)
      write(conn, event: "status", message: "Done")
      write(conn, event: "done", cost: sess.cost.to_s)
    rescue LLM::NoSuchModelError
      write(conn, event: "done", cost: "unknown")
    rescue StandardError => e
      write(conn, event: "status", message: "Error")
      write(conn, event: "error")
    end

    ##
    # Sends a message to the LLM session
    # @param [LLM::Session] sess
    #  The current LLM session
    # @param [String] message
    #  The message to send
    # @return [void]
    def send(sess, message)
      if sess.messages.empty?
        sess.talk initial_prompt(message)
      else
        sess.talk(message.buffer)
      end
    end

    ##
    # Invokes any pending function calls in the LLM session
    # @param [LLM::Session] sess
    #  The current LLM session
    # @param [Async::WebSocket::Adapters::Rack] conn
    #  The WebSocket connection object
    # @return [void]
    def invoke(sess, functions, conn)
      while functions.any?
        functions = sess.functions
        write(conn, event: "status", message: tool_status(functions))
        sess.talk functions.map(&:call)
      end
    end
  end
end
