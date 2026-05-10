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
      write(conn, fragment(:status, status_bar(ctx:)))
      while (message = conn.read)
        dispatch(conn, ctx, parse_message(message), params)
      end
    rescue EOFError, Protocol::WebSocket::ClosedError
      nil
    ensure
      @task = nil
    end

    ##
    # Dispatches an incoming websocket payload to the appropriate handler.
    # @param [Async::WebSocket::Adapters::Rack] conn
    #  The WebSocket connection object
    # @param [Relay::Models::Context] ctx
    #  The current context
    # @param [Hash] payload
    #  The parsed websocket payload
    # @param [Hash] params
    #  The mutable request params for the current turn
    # @return [void]
    def dispatch(conn, ctx, payload, params)
      if interrupt?(payload)
        interrupt!(conn, ctx)
      elsif request_in_flight?
        write(conn, fragment(:status, status_bar(status: "Busy", ctx:)))
      else
        @task = Async { on_message(conn, ctx, payload, params) }
      end
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
    rescue Errno::EPIPE, IOError, Protocol::WebSocket::ClosedError
      nil
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
    def on_message(conn, ctx, payload, params)
      file = attachment_from_payload(payload) || attachment.consume
      prompt = build_prompt(ctx, payload["message"], file)
      return if prompt.empty?
      yield_tools(ctx) do |tools|
        params[:tools] = tools
        vars[:messages].concat [{role: :user, content: prompt}, {role: :assistant, content: +""}]
        write(conn, fragment(:status, status_bar(status: "Thinking...", ctx:)))
        write(conn, fragment(:remove_empty_state)) if vars[:messages].length == 2
        write(conn, fragment(:append_message, message: vars[:messages][-2]))
        write(conn, fragment(:append_message, message: vars[:messages][-1]))
        write(conn, fragment(:input))
        wait_with_heartbeat(conn, proc { talk(ctx, prompt, params) })
        resolve_functions(ctx, conn, params)
      end
      write(conn, fragment(:status, status_bar(ctx:)))
      @contexts = nil
      write(conn, fragment(:contexts, contexts: contexts))
    rescue LLM::Interrupt
      on_interrupt(conn, ctx)
    rescue LLM::NoSuchRegistryError, LLM::NoSuchModelError
      write(conn, fragment(:status, status_bar(cost: "unknown")))
    rescue => e
      pp e.class, e.message, e.backtrace
      write(conn, fragment(:status, status_bar(status: "#{e.class}: #{e.message}")))
    ensure
      @task = nil
    end

    ##
    # Sends a message to the LLM session
    # @param [Relay::Models::Context] ctx
    #  The current context
    # @param [String] message
    #  The message to send
    # @return [void]
    def talk(ctx, prompt, params)
      if ctx.messages.empty?
        ctx.talk initial_prompt(prompt), params
      else
        ctx.talk(prompt, params)
      end
    end

    ##
    # Invokes any pending function calls in the LLM session
    # @param [Relay::Models::Context] ctx
    #  The current context
    # @param [Async::WebSocket::Adapters::Rack] conn
    #  The WebSocket connection object
    # @return [void]
    def resolve_functions(ctx, conn, params)
      while ctx.functions?
        returns = wait_with_heartbeat(conn, proc { ctx.wait(:task) })
        break if returns.empty?
        write(conn, fragment(:status, status_bar(status: tool_status(ctx.functions), ctx:))) if ctx.functions?
        wait_with_heartbeat(conn, proc { ctx.talk(returns, params) })
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
    def fragment(name, locals = nil, **kwargs)
      vars.merge!((locals || {}).merge(kwargs))
      case name
      when :append_message then partial("fragments/append_message", locals: vars)
      when :chat then partial("fragments/stream", locals: vars)
      when :contexts then partial("fragments/settings/replace_contexts", locals: vars)
      when :input then partial("fragments/input", locals: {swap_oob: true})
      when :remove_empty_state then partial("fragments/remove_empty_state")
      when :replace_last_message then partial("fragments/replace_last_message", locals: vars)
      when :status then partial("fragments/status", locals: vars.merge(swap_oob: true))
      end
    end

    ##
    # Parses an incoming websocket frame from HTMX and extracts the message text
    # @param [Protocol::WebSocket::Message] message
    #  The websocket message frame
    # @return [String]
    #  The message text, or an empty string if parsing fails
    def parse_message(message)
      JSON.parse(message.buffer)
    rescue JSON::ParserError
      {}
    end

    ##
    # Returns the fragments variables
    # @return [Hash]
    def vars
      @temp ||= {messages: []}
    end

    def request_in_flight?
      @task&.alive?
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
      runnable = if Proc === runner
        Async { runner.call }
      elsif Array === runner
        Async { runner }
      else
        runner
      end
      while runnable.alive?
        write conn, "<!-- heartbeat -->"
        pause(0.5)
      end
      runnable.wait
    end

    def pause(seconds)
      Async::Task.current.sleep(seconds)
    end

    def build_prompt(ctx, message, file)
      text = message.to_s.strip
      return text if file.nil?
      parts = []
      parts << text unless text.empty?
      parts << ctx.local_file(file.path)
      parts
    end

    def attachment_from_payload(payload)
      path = payload["attachment_path"].to_s
      return if path.empty? || !File.file?(path)
      Relay::Attachment.new(
        name: payload["attachment_name"],
        path:,
        type: payload["attachment_type"]
      )
    end

    ##
    # @param [Relay::Models::Context] servers
    # @yieldparam [Array<LLM::Tool>] tools
    # @return [void]
    def yield_tools(ctx)
      servers = ctx.mcps
      servers.each(&:start)
      yield [*LLM::Tool.registry.reject(&:mcp?), *servers.flat_map(&:tools)]
    ensure
      servers&.each { _1.stop rescue nil }
    end
  end
end
