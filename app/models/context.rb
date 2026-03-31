# frozen_string_literal: true

module Relay::Models
  ##
  # The {Relay::Models::Context} model stores the accumulated model
  # context for a user, provider, and model combination. It persists
  # the underlying {LLM::Session} state as JSON in the "data" column
  # so future turns can continue from the same context window.
  class Context < Sequel::Model
    include Relay::Model

    set_dataset :contexts
    many_to_one :user

    ##
    # @param [LLM::Tracer] tracer
    #  An LLM tracer
    def tracer=(tracer)
      llm.tracer = tracer
    end

    ##
    # @return [LLM::Function]
    #  Returns an array of tools
    def functions
      ctx.functions
    end

    ##
    # Continues the stored context with new input
    # @return [LLM::Response]
    def talk(...)
      ctx.talk(...)
    end

    ##
    # @return [LLM::Object]
    def usage
      LLM::Object.from(
        input_tokens: input_tokens || 0,
        output_tokens: output_tokens || 0,
        total_tokens: total_tokens || 0
      )
    end

    ##
    # Persists the current session state and token usage
    # @return [Relay::Models::Context]
    def persist!
      update(
        input_tokens: ctx.usage.input_tokens,
        output_tokens: ctx.usage.output_tokens,
        total_tokens: ctx.usage.total_tokens,
        data: ctx.to_json
      )
    end

    ##
    # @note
    #  This method excludes tool calls and system messages.
    #  It is safe to render in the UI.
    # @return [Array<Hash>]
    #  Returns persisted user and assistant messages
    def messages
      ctx.messages.filter_map do |message|
        next if message.tool_call?
        next unless message.user? || message.assistant?
        {role: message.role.to_sym, content: message.content.to_s}
      end
    end

    ##
    # @return [LLM::Cost]
    #  Returns the approximate cost of the current context
    def cost
      ctx.cost
    end

    ##
    # @return [Integer]
    def context_window
      ctx.context_window
    rescue LLM::NoSuchModelError, LLM::NoSuchRegistryError
      0
    end

    ##
    # @return [LLM::Provider]
    #  An instance of LLM::Provider
    def llm
      @llm ||= LLM.method(provider).call(key: ENV["#{provider.upcase}_SECRET"], timeout: 300, persistent: true)
    end

    private

    ##
    # @return [LLM::Session]
    #  Returns the context
    def ctx
      @ctx ||= LLM::Context.new(llm, model: self[:model]).restore(string: data)
    end
  end
end
