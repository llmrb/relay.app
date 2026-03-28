# frozen_string_literal: true

module Relay
  require "redcarpet"

  ##
  # Renders markdown to HTML
  # @param [String] text
  #  The markdown source
  # @return [String]
  def self.markdown(text)
    renderer.render(text.to_s.gsub(/\r\n?/, "\n"))
  end

  ##
  # @return [Redcarpet::Markdown]
  #  Returns the shared markdown renderer
  def self.renderer
    Redcarpet::Markdown.new(
      Markdown.new(filter_html: true, safe_links_only: true),
      autolink: true,
      fenced_code_blocks: true,
      lax_spacing: true,
      no_intra_emphasis: true,
      tables: true
    )
  end

  class Markdown < Redcarpet::Render::HTML
    include ERB::Util
    ##
    # Renders fenced code blocks with a language class for highlight.js
    # @param [String] code
    #  The code block contents
    # @param [String, nil] language
    #  The fenced code language
    # @return [String]
    def block_code(code, language)
      language = language.to_s.strip
      language = "plaintext" if language.empty?
      %(<pre><code class="language-#{h(language)}">#{h(code)}</code></pre>)
    end
  end
end
