# frozen_string_literal: true

module Relay::Concerns
  module Attachment
    def attachment
      Relay::Attachment.session(
        session:,
        root: Relay.home,
        user: respond_to?(:user) ? user : nil,
        provider: session["provider"]
      )
    end
  end
end
