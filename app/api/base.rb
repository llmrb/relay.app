# frozen_string_literal: true

module API
  class Base
    ##
    # @return [Rack::Request]
    #  The current Rack request
    attr_reader :request

    ##
    # @return [Hash]
    #  The request params
    attr_reader :params

    ##
    # @param [Hash] env
    #  The Rack env
    # @param [Hash<String,LLM::Provider>] llms
    #  A hashmap of LLM::Provider objects
    # @return [Controller::Base]
    def initialize(env, llms)
      @request = Rack::Request.new(env)
      @params = request.params
      @llms = llms
    end

    ##
    # @return [String]
    #  The requested provider, defaulting to openai
    def provider
      params["provider"] || "openai"
    end

    ##
    # @return [String,nil]
    #  The requested model
    def model
      params["model"]
    end

    ##
    # @return [LLM::Provider]
    #  The selected provider object
    def llm
      @llms[provider] || @llms["openai"]
    end

    ##
    # @return [String]
    #  Returns the root path
    def root
      @root ||= File.join __dir__, "..", ".."
    end
  end
end
