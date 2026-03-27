# frozen_string_literal: true

module Relay::Pages
  ##
  # Renders the chat page.
  class Chat < Base
    prepend Relay::Hooks::RequireUser

    ##
    # @return [String]
    def call
      response["content-type"] = "text/html"
      session["provider"] ||= "deepseek"
      session["model"] ||= "deepseek-chat"
      page("chat", title: "Relay", messages:)
    end

    private

    ##
    # @return [Array<Hash>]
    #  Returns persisted user and assistant messages for the initial page render
    def messages
      ctx.messages.filter_map do |message|
        next if message.tool_call?
        next unless message.user? || message.assistant?

        {role: message.role.to_sym, content: message.content.to_s}
      end
    end
  end
end
