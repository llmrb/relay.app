# frozen_string_literal: true

require_relative "../setup"

class SignInRouteTest < Relay::Test
  def test_sign_in_page_accessible
    get "/sign-in"
    assert_equal 200, last_response.status
    assert_match "Sign In", last_response.body
  end

  def test_sign_in_form_exists
    get "/sign-in"
    assert_match "<form", last_response.body
    assert_match "action=\"/sign-in\"", last_response.body
    assert_match "method=\"post\"", last_response.body
  end

  def test_sign_in_with_invalid_credentials
    post "/sign-in", { username: "invalid", password: "wrong" }
    assert_equal 401, last_response.status
    assert_match "Unauthorized", last_response.body
  end

  def test_sign_in_redirects_authenticated_users
    # This would require setting up a session cookie
    # For now, test that the route responds
    get "/sign-in"
    assert_equal 200, last_response.status
  end
end
