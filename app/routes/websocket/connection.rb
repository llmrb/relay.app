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
    # @param [Relay::Models::Context] ctx
    #  The current context
    # @return [void]
    def on_connect(conn, llm, ctx, params)
      vars[:messages] = ctx.messages
      write(conn, fragment(:status, status: "Ready", cost: format_cost(ctx.cost), context_window: context_window(ctx)))
      while (message = conn.read)
        on_message conn, ctx, parse_message(message), params
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
    # @param [Relay::Models::Context] ctx
    #  The current context
    # @param [String] message
    #  The incoming message
    # @return [void]
    def on_message(conn, ctx, message, params)
      return if message.to_s.empty?
      vars[:messages].concat [{role: :user, content: message}, {role: :assistant, content: +""}]
      write(conn, fragment(:status, status: "Thinking..."))
      write(conn, fragment(:remove_empty_state)) if vars[:messages].length == 2
      write(conn, fragment(:append_message, message: vars[:messages][-2]))
      write(conn, fragment(:append_message, message: vars[:messages][-1]))
      write(conn, fragment(:input))
      wait_with_heartbeat(conn, proc { talk(ctx, message, params) })
      resolve_functions(ctx, ctx.functions, conn, params)
      persist(ctx)
      write(conn, fragment(:status, status: "Ready", context_window: context_window(ctx), cost: format_cost(ctx.cost)))
    rescue LLM::NoSuchRegistryError, LLM::NoSuchModelError
      write(conn, fragment(:status, cost: "unknown", status: "Ready"))
    rescue StandardError => e
      pp e.class, e.message, e.backtrace
      write(conn, fragment(:status, status: "Error"))
    end

    ##
    # Sends a message to the LLM session
    # @param [Relay::Models::Context] ctx
    #  The current context
    # @param [String] message
    #  The message to send
    # @return [void]
    def talk(ctx, message, params)
      if ctx.messages.empty?
        ctx.talk initial_prompt(message), params
      else
        ctx.talk(message, params)
      end
    end

    ##
    # Invokes any pending function calls in the LLM session
    # @param [Relay::Models::Context] ctx
    #  The current context
    # @param [Async::WebSocket::Adapters::Rack] conn
    #  The WebSocket connection object
    # @return [void]
    def resolve_functions(ctx, functions, conn, params)
      return if functions.empty?
      write(conn, fragment(:status, status: tool_status(functions)))
      returns = wait_with_heartbeat(conn, functions.spawn)
      wait_with_heartbeat(conn, proc { ctx.talk(returns, params) })
      if ctx.functions.any?
        resolve_functions(ctx, ctx.functions, conn, params)
      end
    end

    ##
    # Persists the current context after a websocket turn completes
    # @param [Relay::Models::Context] ctx
    #  The current context
    # @return [Relay::Models::Context]
    def persist(ctx)
      ctx.persist!
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
      write conn, fragment(:replace_last_message, message:)
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
      when :append_message then partial("fragments/append_message", locals: vars)
      when :chat then partial("fragments/stream", locals: vars)
      when :input then partial("fragments/input")
      when :remove_empty_state then partial("fragments/remove_empty_state")
      when :replace_last_message then partial("fragments/replace_last_message", locals: vars)
      when :status then partial("fragments/status", locals: vars)
      end
    end

    ##
    # Returns session token usage against the model context window
    # @param [LLM::Session] sess
    #  The current LLM session
    # @return [Hash]
    #  The current token usage, maximum window, and display label
    def context_window(sess)
      used, max = sess.usage.total_tokens || 0,  sess.context_window || 0
      {used:, max:, label: "#{used} / #{max} tokens" }
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

    ##
    # Waits for a runnable to finish while sending websocket heartbeats
    # @param [LLM::Function::ThreadGroup, Proc] runnable
    #  The runnable value to wait for
    # @param [Async::WebSocket::Adapters::Rack] conn
    #  The WebSocket connection object
    # @return [Array<LLM::Function::Return>, nil]
    #  Returns thread-group values, or nil for proc work
    def wait_with_heartbeat(conn, runner)
      if Proc === runner
        runnable = Thread.new { runner.call }
      else
        runnable = runner
      end
      while runnable.alive?
        write conn, "<!-- heartbeat -->"
        pause(0.5)
      end
      runnable.value
    end

    def pause(seconds)
      Async::Task.current.sleep(seconds)
    end
  end
end
