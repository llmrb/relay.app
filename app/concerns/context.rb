# frozen_string_literal: true

module Relay::Concerns
  ##
  # Shared Relay provider, model, and persisted context selection.
  #
  # This concern centralizes the session-backed logic for resolving the
  # current provider, chat model, and
  # {Relay::Models::Context Relay::Models::Context} so pages and routes
  # stay in sync.
  module Context
    ##
    # @return [String]
    #  The requested provider, defaulting to deepseek.
    def provider
      session["provider"] || "deepseek"
    end

    ##
    # @return [String, nil]
    #  The requested model.
    def model
      session["model"] = normalize_model(session["model"])
    end

    ##
    # @return [LLM::Provider]
    #  The selected provider object.
    def llm
      ctx.llm
    end

    ##
    # @return [Relay::Models::Context]
    #  The active persisted context for the current user and provider.
    def ctx
      @ctx ||= begin
        context = current_context || default_context
        sync_context!(context)
      end
    end

    ##
    # @return [Array<Relay::Models::Context>]
    #  Saved contexts for the current user and provider, newest first.
    def contexts
      @contexts ||= Relay::Models::Context.where(user_id: user.id, provider:)
        .reverse_order(:updated_at)
        .all
        .select { valid_model?(_1[:model]) }
        .select { _1.messages.any? }
    end

    ##
    # @return [Array<Relay::Models::MCP>]
    #  Saved MCP servers for the current user, newest first.
    def mcps
      @mcps ||= user ? Relay::Models::MCP.summary_dataset(user.mcps_dataset)
        .reverse_order(:created_at)
        .all : []
    end

    ##
    # @return [Relay::Models::Context, nil]
    #  The currently selected context for the session, if it matches the
    #  current provider.
    def current_context
      return unless session["context_id"]
      context = Relay::Models::Context.where(user_id: user.id, provider:, id: session["context_id"]).first
      return context if context && valid_model?(context[:model])
      session.delete("context_id")
      nil
    end

    ##
    # @return [Relay::Models::Context]
    #  The default context for the current provider/model selection.
    def default_context
      Relay::Models::Context.where(user_id: user.id, provider:, model:)
        .reverse_order(:updated_at)
        .first || Relay::Models::Context.create(user_id: user.id, provider:, model:)
    end

    ##
    # @param [Relay::Models::Context] context
    # @return [Relay::Models::Context]
    def sync_context!(context)
      session["context_id"] = context.id
      session["model"] = normalize_model(context[:model])
      context
    end

    ##
    # @return [Hash<String, LLM::Provider>]
    #  A map of initialized LLM providers.
    def llms
      Relay.providers
    end

    ##
    # @return [Array<Relay::Models::ModelRecord>]
    #  Models for the current provider.
    def models
      Relay::Models::ModelRecord.where(provider:).order(:name).all
    end

    ##
    # @return [String]
    #  Returns the default chat model for the current provider.
    def default_model
      case (provider = llms[self.provider]).name
      when :deepseek then "deepseek-v4-flash"
      when :openai then "gpt-5.4"
      when :xai then "grok-3"
      else provider.default_model
      end
    end

    ##
    # @param [String, nil] id
    # @return [Boolean]
    def valid_model?(id)
      models.any? { _1.model_id == id }
    end

    ##
    # @param [String, nil] id
    # @return [String]
    def normalize_model(id)
      return id if id && valid_model?(id)
      default_model
    end

    ##
    # @return [Relay::Models::User, nil]
    def user
      @user ||= Relay::Models::User[session["user_id"]] if session["user_id"]
    end
  end
end
