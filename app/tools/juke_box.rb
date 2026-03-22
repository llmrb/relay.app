# frozen_string_literal: true

require "yaml"

module Relay::Tools
  ##
  # The {Relay::Tools::JukeBox} plays my favorite songs whenever
  # I'm bored. The jukebox is maintained by the resources/jukebox.yml
  # file and it can be edited to suit your own tastes.
  class JukeBox < Base
    name "jukebox"
    description "Provides a list of music videos that can be embedded into the chat"

    ##
    # @param [String] category
    #  The music category
    # @return [Hash]
    #  Returns an iframe with an embed
    def call
      jukebox.map do |j|
        {directions: "cache the jukebox", iframe: iframe(j)}
      end
    end

    private

    def iframe(j)
      data = File.read File.join(Relay.fragments_dir, "_jukebox.erb")
      ERB.new(data).result_with_hash(j:)
    end

    def jukebox
      YAML.safe_load(
        File.read(File.join(Relay.resources_dir, "jukebox.yml")),
        permitted_classes: [],
        aliases: false
      )
    end
  end
end
