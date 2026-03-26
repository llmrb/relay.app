# frozen_string_literal: true

module Relay::Routes
  ##
  # Handles authentication for the sign-in form.
  class SignIn < Base
    include Relay::Models

    ##
    # Authenticates a user and stores their session
    # @return [void]
    def call
      user = find_user
      if user&.authenticate(params["password"])
        sign_in(user)
        r.redirect("/")
      else
        response.status = 401
        response["content-type"] = "text/plain"
        "Unauthorized"
      end
    end

    private

    ##
    # Finds the user for the submitted email address
    # @return [Relay::Models::User, nil]
    def find_user
      User.where(email: params["email"] || params["username"]).first
    end

    ##
    # Persists the authenticated user in the session
    # @param [Relay::Models::User] user
    # @return [void]
    def sign_in(user)
      session["user_id"] = user.id
    end
  end
end
