# frozen_string_literal: true

module Relay::Models
  ##
  # The {Relay::Models::MCP::Preset} module defines the preset catalog
  # and compilation rules for Relay MCP servers.
  module MCP::Preset
    extend self

    PRESETS = {
      "github" => {
        id: "github",
        title: "GitHub",
        summary: "Connect GitHub with a single token.",
        transport: "http",
        data: {"preset" => "github", "url" => "https://api.githubcopilot.com/mcp/", "headers" => {}},
        description: "Uses GitHub's hosted MCP endpoint with a Bearer token."
      },
      "forgejo" => {
        id: "forgejo",
        title: "Forgejo",
        summary: "Connect a Forgejo instance with URL and token.",
        transport: "stdio",
        data: {"preset" => "forgejo", "argv" => ["forgejo-mcp"], "cwd" => "", "env" => {}},
        description: "Expects and recommends forgejo-mcp from https://codeberg.org/goern/forgejo-mcp."
      }
    }.freeze

    ##
    # @return [Array<Hash>]
    #  Returns all visible MCP presets
    def all
      PRESETS.values
    end

    ##
    # @param [String, Symbol] id
    #  The MCP preset id
    # @return [Hash, nil]
    #  Returns the preset definition for the given id
    def [](id)
      PRESETS[id.to_s]
    end

    ##
    # @param [Relay::Forms::MCP] form
    #  The preset-specific MCP form
    # @return [Hash]
    #  The persisted MCP model attributes for the preset
    def attributes_for(form)
      preset = self[form.preset]
      {
        name: preset[:title],
        description: "",
        transport: preset[:transport],
        data: preset[:data].merge(form.data)
      }
    end
  end
end
