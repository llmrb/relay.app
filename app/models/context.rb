# frozen_string_literal: true

module Relay::Models
  ##
  # The {Relay::Models::Context} model stores the accumulated model
  # context for a user, provider, and model combination. It persists
  # the underlying {LLM::Session} state as JSON in the "data" column
  # so future turns can continue from the same context window.
  class Context < Sequel::Model
    include Relay::Model
    plugin :llm, provider: :set_provider, tracer: :set_tracer

    set_dataset :contexts
    many_to_one :user

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

    private

    def set_provider
      {key: ENV["#{provider.upcase}_SECRET"], persistent: true}
    end

    def set_tracer
      path = File.join(Relay.logs_dir, "#{provider}-#{Date.today.iso8601}.log")
      LLM::Tracer::Logger.new(llm, path:)
    end
  end
end
