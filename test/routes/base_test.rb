# frozen_string_literal: true

require "setup"

class BaseRouteTest < Relay::Test
  def test_root_path_redirects_to_sign_in
    get "/"
    assert_equal 302, last_response.status
    assert_match "/sign-in", last_response.headers["Location"]
  end

  def test_unknown_get_route_returns_404
    get "/nonexistent-route"
    assert_equal 404, last_response.status
  end
end
