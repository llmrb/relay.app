# frozen_string_literal: true

module Relay::Tools
  ##
  # The {Relay::Tools::RelayKnowledge} tool provides the LLM
  # with knowledge about Relay through its README documentation.
  # This helps inform the LLM what about Relay is and what it does,
  # since it is unlikely to be heard of by an LLM.
  class RelayKnowledge < LLM::Tool
    include Relay::Tool

    name "relay-knowledge"
    description "Returns Relay, llm.rb or mruby-llm documentation"
    parameter :topic, Enum["relay", "llm.rb", "mruby-llm"], "The knowledge topic"
    required %i[topic]

    ##
    # Provides the Relay documentation
    # @return [Hash]
    def call(topic:)
      case topic
      when "relay" then {directions:, documentation: fetch(relay_resources)}
      when "llm.rb" then {directions:, documentation: fetch(llmrb_resources)}
      when "mruby-llm" then {directions:, documentation: fetch(mruby_llm_resources)}
      else {error: "unknown topic: #{topic}"}
      end
    end

    private

    def fetch(resources)
      resources.each_with_object({}) do |(key, url), h|
        res = Net::HTTP.get_response URI.parse(url)
        h[key] = res.body
      end
    end

    def relay_resources
      {"readme" => "https://raw.githubusercontent.com/llmrb/relay/refs/heads/main/README.md"}
    end

    def llmrb_resources
      {
        "readme"   => "https://raw.githubusercontent.com/llmrb/llm.rb/refs/heads/main/README.md",
        "deepdive" => "https://raw.githubusercontent.com/llmrb/llm.rb/refs/heads/main/resources/deepdive.md",
        "changelog" => "https://raw.githubusercontent.com/llmrb/llm.rb/refs/heads/main/CHANGELOG.md"
      }
    end

    def mruby_llm_resources
      {
        "readme" => "https://raw.githubusercontent.com/llmrb/mruby-llm/refs/heads/main/README.md"
      }
    end

    def directions
      "Reference links from the associated document in your response"
    end
  end
end
