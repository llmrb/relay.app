# frozen_string_literal: true

module Relay::Models
  ##
  # The {Relay::Models::Context} model stores the accumulated model
  # context for a user, provider, and model combination. It persists
  # the underlying {LLM::Session} state as JSON in the "data" column
  # so future turns can continue from the same context window.
  class Context < Sequel::Model
    include Relay::Model
    plugin :llm, provider: :set_provider, context: :set_context, tracer: :set_tracer

    set_dataset :contexts
    many_to_one :user

    ##
    # @return [String, nil]
    #  Returns the first persisted user message content.
    def title
      ctx.messages.find(&:user?)&.content
    end

    ##
    # @return [Array<Relay::Models::MCP>]
    #  Enabled MCP servers for this context's user.
    def mcps
      user ? user.mcps_dataset.where(enabled: true).all : []
    end

    ##
    # @return [LLM::Compactor]
    #  Returns the runtime compactor for the persisted context.
    def compactor
      ctx.compactor
    end

    ##
    # @return [Boolean]
    #  Returns true when the underlying llm.rb context is in a
    #  post-compaction state.
    def compacted?
      ctx.compacted?
    end

    ##
    # @note
    #  This method excludes tool calls and system messages.
    #  It is safe to render in the UI.
    # @return [Array<Hash>]
    #  Returns persisted user and assistant messages
    def messages
      ctx.messages.filter_map do |message|
        next if message.tool_call? || message.compaction?
        next unless message.user? || message.assistant?
        {role: message.role.to_sym, content: message.content.to_s}
      end
    end

    ##
    # @return [Integer]
    def context_window
      super
    rescue LLM::NoSuchModelError, LLM::NoSuchRegistryError
      0
    end

    private

    def set_provider
      LLM.method(provider).call(key: ENV["#{provider.upcase}_SECRET"], persistent: true)
    end

    def set_context
      {model: self[:model], compactor: {retention_window: 8, token_threshold: "95%"}}
    end

    def set_tracer
      path = File.join(Relay.logs_dir, "#{provider}-#{Date.today.iso8601}.log")
      LLM::Tracer::Logger.new(llm, path:)
    end
  end
end
