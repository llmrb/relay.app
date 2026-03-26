# frozen_string_literal: true

require "protocol/websocket/message"

class Relay::Routes::Websocket
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
      write(conn, fragment(:status, status: "Ready", cost: "$0.00", context_window: context_window(sess)))
      while (message = conn.read)
        read conn, sess, parse_message(message)
      end
    rescue EOFError
      nil
    end

    ##
    # Writes an HTML fragment to the websocket as a text frame
    # @param [Async::WebSocket::Adapters::Rack] conn
    #  The WebSocket connection object
    # @param [String] message
    #  The rendered HTML fragment
    # @return [void]
    def write(conn, message)
      conn.write(Protocol::WebSocket::TextMessage.new(String(message)))
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
      return if message.to_s.empty?
      vars[:messages].concat [{role: :user, content: message}, {role: :assistant, content: +""}]
      write(conn, fragment(:status, status: "Thinking..."))
      write(conn, fragment(:chat))
      write(conn, fragment(:input))
      send(sess, message)
      invoke(sess, sess.functions, conn)
      write(conn, fragment(:status, status: "Ready", context_window: context_window(sess), cost: format_cost(sess.cost)))
    rescue LLM::NoSuchRegistryError, LLM::NoSuchModelError
      write(conn, fragment(:status, cost: "unknown", status: "Ready"))
    rescue StandardError => e
      pp e.class, e.message, e.backtrace
      write(conn, fragment(:status, status: "Error"))
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
        sess.talk(message)
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
        write(conn, fragment(:status, status: tool_status(functions)))
        sess.talk functions.map(&:call)
        functions = sess.functions
      end
    end

    ##
    # Appends a streamed assistant chunk to the last assistant message and re-renders chat
    # @param [Async::WebSocket::Adapters::Rack] conn
    #  The WebSocket connection object
    # @param [String] chunk
    #  The streamed assistant text chunk
    # @return [void]
    def stream(conn, chunk)
      message = vars[:messages].reverse_each.find { _1[:role] == :assistant }
      message[:content] << chunk
      write conn, fragment(:chat)
    end

    ##
    # Renders a websocket fragment using the retained fragment state
    # @param [Symbol] name
    #  The fragment name
    # @param [Hash] locals
    #  The local values to merge into the retained fragment state
    # @return [String]
    #  The rendered HTML fragment
    def fragment(name, **locals)
      vars.merge!(locals)
      case name
      when :chat then partial("fragments/stream", locals: vars)
      when :status then partial("fragments/status", locals: vars)
      when :input then partial("fragments/input")
      end
    end

    ##
    # Returns session token usage against the model context window
    # @param [LLM::Session] sess
    #  The current LLM session
    # @return [Hash]
    #  The current token usage, maximum window, and display label
    def context_window(sess)
      { used: sess.usage.total_tokens || 0,
        max: sess.context_window || 0,
        label: "#{used} / #{max} tokens" }
    end

    ##
    # Formats the session cost for display
    # @param [String] cost
    #  The raw session cost
    # @return [String]
    #  The formatted cost string
    def format_cost(cost)
      return "unknown" if cost == "unknown"

      "$#{cost}"
    end

    ##
    # Parses an incoming websocket frame from HTMX and extracts the message text
    # @param [Protocol::WebSocket::Message] message
    #  The websocket message frame
    # @return [String]
    #  The message text, or an empty string if parsing fails
    def parse_message(message)
      buffer = JSON.parse(message.buffer)
      buffer['message']
    rescue JSON::ParserError
      ""
    end

    ##
    # Returns the fragments variables
    # @return [Hash]
    def vars
      @temp ||= { messages: [] }
    end
  end
end
