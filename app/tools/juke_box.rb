# frozen_string_literal: true

module Relay::Tools
  ##
  # Returns the built-in jukebox playlist and embeddable iframe HTML for
  # each track. The playlist is maintained in resources/jukebox.yml.
  class JukeBox < LLM::Tool
    include Relay::Tool

    name "jukebox"
    description "Returns a small built-in playlist of playable music videos"

    ##
    # @return [Array<Hash>]
    def call
      jukebox.load.map do |entry|
        {
          name: entry["name"],
          title: entry["title"],
          track: entry["track"],
          html: Relay.erb("fragments/_iframe.erb", {entry:}),
          directions:,
        }
      end
    end

    private

    def jukebox
      @jukebox ||= Relay::Jukebox.new
    end

    def directions
      [
        "Use the list to tell the user what songs are available.",
        "When the user wants to play a specific track, embed that track's iframe HTML exactly as returned.",
        "Do not use `data-play` attributes."
      ]
    end
  end
end
