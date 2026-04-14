# frozen_string_literal: true

module Relay::Tools
  ##
  # The {Relay::Tools::RelayKnowledge} tool provides the LLM
  # with knowledge about Relay through its README documentation.
  # This helps inform the LLM what about Relay is and what it does,
  # since it is unlikely to be heard of by an LLM.
  class RelayKnowledge < Base
    name "relay-knowledge"
    description "Returns Relay or llm.rb documentation so answers can cite project details"
    param :topic, Enum["relay", "llm.rb"], "The knowledge topic", required: true

    ##
    # Provides the Relay documentation
    # @return [Hash]
    def call(topic:)
      case topic
      when "relay" then {directions:, documentation: relay_documentation}
      when "llm.rb" then {directions:, documentation: llmrb_documentation}
      else {error: "unknown topic: #{topic}"}
      end
    end

    private

    def relay_documentation
      relay_resources.each_with_object({}) do |(key, url), h|
        res = Net::HTTP.get_response URI.parse(url)
        h[key] = res.body
      end
    end

    def relay_resources
      {"readme" => "https://raw.githubusercontent.com/llmrb/relay/refs/heads/main/README.md"}
    end

    def llmrb_documentation
      llmrb_resources.each_with_object({}) do |(key, url), h|
        res = Net::HTTP.get_response URI.parse(url)
        h[key] = res.body
      end
    end

    def llmrb_resources
      {
        "readme"   => "https://raw.githubusercontent.com/llmrb/llm.rb/refs/heads/main/README.md",
        "deepdive" => "https://raw.githubusercontent.com/llmrb/llm.rb/refs/heads/main/resources/deepdive.md"
      }
    end

    def directions
      "Reference links from the associated document in your response"
    end
  end
end
