# frozen_string_literal: true

module Relay::Routes
  class Settings::SetProvider < Base
    ##
    # Changes the active provider
    # @return [String]
    #  Returns a HTML fragment
    def call
      set_provider
      set_model
      partial("fragments/settings/set_provider", locals:)
    end

    private

    ##
    # Sets the provider
    # @return [void]
    def set_provider
      session["provider"] = params["provider"]
    end

    ##
    # Sets the model
    # @return [void]
    def set_model
      session["model"] = default_model
    end

    ##
    # @return [Hash]
    #   Returns template locals
    def locals
      {models: cache.models}
    end

    ##
    # @return [String]
    #   Returns the default model
    def default_model
      case (llm = llms[provider]).name
      when :openai then "gpt-5.4"
      when :xai then "grok-3"
      else llm.default_model
      end
    end
  end
end
