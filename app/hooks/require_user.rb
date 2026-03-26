# frozen_string_literal: true

module Relay::Hooks
  module RequireUser
    def call
      @user = Relay::Models::User[session["user_id"]]
      return super unless @user.nil?

      response.status = 401
      response["content-type"] = "application/json"
      {error: "Unauthorized"}.to_json
    end
  end
end
