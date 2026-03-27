# frozen_string_literal: true

module Relay::Models
  class Session < Sequel::Model
    set_dataset :sessions

    many_to_one :user

    ##
    # Serializes an LLM::Session object to JSON and stores it in session_data
    # @param [LLM::Session] llm_session
    def llm_session=(llm_session)
      self.session_data = llm_session.to_json
    end

    ##
    # Deserializes an LLM::Session object from stored JSON
    # @param [LLM::Provider] llm_provider
    # @return [LLM::Session]
    def to_llm_session(llm_provider)
      LLM::Session.new(llm_provider).restore(string: session_data.to_json)
    end

    ##
    # Updates token counts from an LLM::Response or LLM::Session
    # @param [LLM::Response, LLM::Session] source
    def update_tokens_from(source)
      if source.is_a?(LLM::Response)
        self.input_tokens = source.input_tokens.to_i
        self.output_tokens = source.output_tokens.to_i
        self.total_tokens = source.total_tokens.to_i
      elsif source.is_a?(LLM::Session)
        self.input_tokens = source.input_tokens.to_i
        self.output_tokens = source.output_tokens.to_i
        self.total_tokens = source.total_tokens.to_i
      end
    end

    ##
    # Hook to set timestamps before creation
    def before_create
      self.created_at = Time.now
      self.updated_at = Time.now
      super
    end

    ##
    # Hook to update timestamp before save
    def before_save
      self.updated_at = Time.now
      super
    end
  end
end