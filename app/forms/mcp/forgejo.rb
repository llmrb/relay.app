# frozen_string_literal: true

class Relay::Forms::MCP
  ##
  # The {Relay::Forms::MCP::Forgejo} class represents form state for
  # Relay's Forgejo MCP preset.
  class Forgejo < self
    ##
    # @return [String]
    #  Returns the Forgejo instance URL
    attr_reader :url

    ##
    # @return [String]
    #  Returns the Forgejo access token
    attr_reader :token

    ##
    # @param [String] url The Forgejo instance URL
    # @param [String] token The Forgejo access token
    # @param [Hash] attributes
    # @return [Relay::Forms::MCP::Forgejo]
    def initialize(url: "", token: "", **attributes)
      super(**attributes)
      @url = url.to_s.strip
      @token = token.to_s.strip
    end

    ##
    # @return [String]
    #  Returns the preset id
    def preset
      "forgejo"
    end

    ##
    # @return [String]
    #  Returns the backing MCP transport
    def transport
      "stdio"
    end

    ##
    # @return [Hash]
    #  Returns the preset-specific MCP data overrides
    def data
      {
        "argv" => {
          "-url" => url,
          "-token" => token,
          "-transport" => "stdio"
        }
      }
    end
  end
end
