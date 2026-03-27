# frozen_string_literal: true

module Relay::Pages
  ##
  # Base class for full-page renderers.
  class Base
    include Relay::Models

    ##
    # @param [Roda] roda
    # @return [Relay::Pages::Base]
    def initialize(roda)
      @roda = roda
    end

    ##
    # @return [String]
    #  The requested provider, defaulting to deepseek
    def provider
      session["provider"] || "deepseek"
    end

    ##
    # @return [String]
    #  The requested model, defaulting to deepseek-chat
    def model
      session["model"] || "deepseek-chat"
    end

    ##
    # @return [Relay::Models::Context]
    #  The current context for the user, provider, and model
    def ctx
      @ctx ||= Context.find_or_create(user_id: user.id, provider:, model:)
    end

    ##
    # @return [Relay::Models::User, nil]
    def user
      @user
    end

    ##
    # @return [Roda::RodaRequest]
    #  Alias the request object as `r` to match Roda route blocks.
    def r
      @roda.request
    end

    private

    ##
    # Renders a page template with the shared layout.
    # @param [String] name
    # @param [Hash] locals
    # @return [String]
    def page(name, **locals)
      view(File.join("pages", name), locals:, layout_opts: {locals:})
    end

    ##
    # @return [Roda::RodaRequest]
    #  Alias the request object as `r` to match Roda route blocks.
    def r
      @roda.request
    end

    ##
    # Delegate missing methods to the current Roda instance.
    def method_missing(name, *args, **kwargs, &block)
      if @roda.respond_to?(name)
        @roda.send(name, *args, **kwargs, &block)
      else
        super
      end
    end
  end
end
