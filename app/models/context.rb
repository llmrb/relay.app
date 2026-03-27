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
      session.functions
    end

    ##
    # Continues the stored context with new input
    # @return [LLM::Response]
    def talk(...)
      session.talk(...)
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
        input_tokens: session.usage.input_tokens,
        output_tokens: session.usage.output_tokens,
        total_tokens: session.usage.total_tokens,
        data: session.to_json
      )
    end

    ##
    # @return [LLM::Buffer<LLM::Message>]
    #  Returns the messages in the current context
    def messages
      session.messages
    end

    ##
    # @return [LLM::Cost]
    #  Returns the approximate cost of the current context
    def cost
      session.cost
    end

    ##
    # @return [Integer]
    def context_window
      session.context_window
    rescue LLM::NoSuchModelError, LLM::NoSuchRegistryError
      0
    end

    ##
    # @return [LLM::Provider]
    #  An instance of LLM::Provider
    def llm
      @llm ||= LLM.method(provider).call(key: ENV["#{provider.upcase}_SECRET"])
    end

    private

    ##
    # @return [LLM::Session]
    #  Returns an instance of LLM::Session
    def session
      @session ||= LLM::Session.new(llm, model: self[:model]).restore(string: data)
    end
  end
end
