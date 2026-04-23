# frozen_string_literal: true

require "cgi"
require "uri"
require "yaml"

module Relay::Tools
  module JukeboxStore
    module_function

    def path
      File.join(Relay.resources_dir, "jukebox.yml")
    end

    def load
      deduplicate(YAML.safe_load_file(path, permitted_classes: [], aliases: false) || [])
    end

    def save(entries)
      File.write(path, YAML.dump(deduplicate(entries)))
    end

    def normalize_track(url)
      uri = URI.parse(url.to_s.strip)
      host = uri.host.to_s.downcase
      video_id =
        case host
        when "youtu.be"
          uri.path.split("/").reject(&:empty?).first
        when "youtube.com", "www.youtube.com", "m.youtube.com",
             "youtube-nocookie.com", "www.youtube-nocookie.com"
          extract_youtube_id(uri)
        end
      raise ArgumentError, "unsupported YouTube URL" if video_id.to_s.empty?
      "https://www.youtube-nocookie.com/embed/#{video_id}"
    rescue URI::InvalidURIError
      raise ArgumentError, "invalid YouTube URL"
    end

    def remove(name:, title: nil, track: nil)
      entries = load
      before = entries.length
      normalized_name = normalize_text(name)
      normalized_title = title && normalize_text(title)
      normalized_track = track && normalize_track(track)
      entries.reject! do |entry|
        next false unless normalize_text(entry["name"]) == normalized_name
        next false if normalized_title && normalize_text(entry["title"]) != normalized_title
        next false if normalized_track && normalize_track(entry["track"]) != normalized_track
        true
      end
      save(entries) if entries.length != before
      before - entries.length
    end

    def add(name:, title:, track:)
      entries = load
      normalized_track = normalize_track(track)
      entry = {"name" => scrub_text(name), "title" => scrub_text(title), "track" => normalized_track}
      raise ArgumentError, "name is required" if entry["name"].empty?
      raise ArgumentError, "title is required" if entry["title"].empty?
      entries.reject! do |existing|
        same_track?(existing, entry) || same_song?(existing, entry)
      end
      entries << entry
      save(entries)
      entry
    end

    def extract_youtube_id(uri)
      path = uri.path.to_s
      return path.split("/").reject(&:empty?).last if path.start_with?("/embed/", "/shorts/")
      CGI.parse(uri.query.to_s).fetch("v", []).first
    end

    def deduplicate(entries)
      entries.each_with_object([]) do |entry, acc|
        candidate = normalize_entry(entry)
        next if candidate.nil?
        next if acc.any? { same_track?(_1, candidate) || same_song?(_1, candidate) }
        acc << candidate
      end
    end

    def normalize_entry(entry)
      name = scrub_text(entry["name"])
      title = scrub_text(entry["title"])
      track = normalize_track(entry["track"])
      return nil if name.empty? || title.empty? || track.empty?
      {"name" => name, "title" => title, "track" => track}
    rescue ArgumentError
      nil
    end

    def same_track?(left, right)
      normalize_track(left["track"]) == normalize_track(right["track"])
    rescue ArgumentError
      false
    end

    def same_song?(left, right)
      normalize_text(left["name"]) == normalize_text(right["name"]) &&
        normalize_text(left["title"]) == normalize_text(right["title"])
    end

    def scrub_text(value)
      value.to_s.strip.gsub(/\s+/, " ")
    end

    def normalize_text(value)
      scrub_text(value).downcase
    end
  end
end
