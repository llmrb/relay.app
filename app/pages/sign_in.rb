# frozen_string_literal: true

module Relay::Pages
  ##
  # Renders the sign-in page.
  class SignIn < Base
    ##
    # @return [String]
    def call
      response["content-type"] = "text/html"
      page("sign_in", title: "Relay: Sign In")
    end
  end
end
