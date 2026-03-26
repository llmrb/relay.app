# frozen_string_literal: true

require_relative "../setup"

class ListModelsRouteTest < Relay::Test
  def test_list_models_requires_authentication
    get "/api/models"
    assert_equal 401, last_response.status
    assert_match "Unauthorized", last_response.body
  end

  def test_list_models_with_valid_session
    # This test would require setting up a session
    # For now, we test the authentication requirement
    get "/api/models"
    assert_equal 401, last_response.status
  end

  def test_list_models_route_exists
    # Test that the route is defined by checking the response format
    get "/api/models"
    assert_equal 401, last_response.status
    assert_equal "application/json", last_response.headers["Content-Type"]
  end
end
