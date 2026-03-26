# frozen_string_literal: true

require_relative "../setup"

class BaseRouteTest < Relay::Test
  def test_root_path_redirects_to_sign_in
    get "/"
    assert_equal 302, last_response.status
    assert_match "/sign-in", last_response.headers["Location"]
  end

  def test_health_check_returns_ok
    get "/health"
    assert_equal 200, last_response.status
    assert_equal "OK", last_response.body
  end

  def test_not_found_returns_404
    get "/nonexistent-route"
    assert_equal 404, last_response.status
    assert_match "Not Found", last_response.body
  end
end
