# frozen_string_literal: true

module Relay
  ##
  # Reloads Zeitwerk-managed application code on each request in
  # development before passing control to the downstream Rack app.
  class Reloader
    ##
    # @param [#call] app
    # @return [Relay::Reloader]
    def initialize(app)
      @app = app
    end

    ##
    # @param [Hash] env
    # @return [Array(Integer, Hash, #each)]
    def call(env)
      reload!
      @app.call(env)
    end

    private

    def reload!
      Relay.loader.reload
    end
  end
end
