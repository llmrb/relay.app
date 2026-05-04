# frozen_string_literal: true

module Relay::Pages
  ##
  # Base class for full-page renderers.
  class Base
    include Relay::Models
    include Relay::Concerns::Attachment
    include Relay::Concerns::Context
    include Relay::Concerns::Roda
    include Relay::Concerns::View

    private

    ##
    # Renders a page template with the shared layout.
    # @param [String] name
    # @param [Hash] locals
    # @return [String]
    def page(name, **locals)
      view(File.join("pages", name), locals:, layout_opts: {locals:})
    end
  end
end
