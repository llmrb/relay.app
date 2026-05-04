# frozen_string_literal: true

module Relay::Routes
  class Base
    include Relay::Models
    include Relay::Concerns::Attachment
    include Relay::Concerns::Context
    include Relay::Concerns::Roda
    include Relay::Concerns::View

    ##
    # @return [String]
    #  Returns the root path
    def root
      @root ||= File.join __dir__, "..", ".."
    end

    ##
    # Returns a Hash or Hash-like object of request parameters
    # @return [Hash]
    def params
      request.params
    end

    ##
    # @return [Relay::InMemoryCache]
    def cache
      Relay.cache
    end

    def htmx?
      request.env["HTTP_HX_REQUEST"] == "true"
    end
  end
end
