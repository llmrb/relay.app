# frozen_string_literal: true

module Relay::Tools
  class Apropos < Base
    name "apropos"
    description "Searches local apropos/man page indexes and returns matching FreeBSD man page entries"
    param :query, String, "The man page search query", required: true
    param :limit, Integer, "Maximum number of matches to return", default: 10

    def call(query:, limit: 10)
      command = cmd("apropos", query.to_s)
      if command.success?
        matches = parse(command.stdout).first(normalize_limit(limit))
        if matches.empty?
          {query:, matches: [], message: "No matching man pages found"}
        else
          {query:, matches:, directions:}
        end
      elsif command.not_found?
        {error: "apropos_not_found", message: "The apropos command is not available on this system"}
      else
        {error: "apropos_failed", message: command.stderr.to_s.strip}
      end
    end

    private

    def normalize_limit(limit)
      [[limit.to_i, 1].max, 25].min
    end

    def parse(output)
      output.to_s.each_line(chomp: true).filter_map do |line|
        next if line.strip.empty?
        name, summary = line.split(/\s+-\s+/, 2)
        next unless name
        {
          entry: name.strip,
          summary: summary.to_s.strip
        }
      end
    end

    def directions
      "Use the returned entries as man page candidates; cite the exact man entry name when recommending one"
    end
  end
end
