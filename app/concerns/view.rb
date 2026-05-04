# frozen_string_literal: true

module Relay::Concerns
  ##
  # Shared view-layer functionality for page and route renderers.
  #
  # This concern exists to hold presentation-focused helpers that shape
  # data for templates and fragments, such as status-bar labels and
  # formatted cost/context-window values. Keeping these helpers here
  # separates view concerns from session/context resolution.
  module View
    ##
    # @param [#to_s] text
    # @return [String]
    #  Returns up to two initials for compact UI badges.
    def initials(text)
      words = text.to_s.strip.split(/\s+/).reject(&:empty?)
      return "?" if words.empty?
      words.first(2).map { _1[0] }.join.upcase
    end

    ##
    # @param [String] text
    # @return [String]
    #  Renders markdown to HTML for templates and fragments.
    def markdown(text)
      Relay.markdown(text)
    end

    ##
    # @return [Hash]
    #  Returns the status-bar payload for the current context.
    def status_bar(status: "Ready", ctx: self.ctx, context_window: nil, cost: nil)
      {
        status:,
        context_window: context_window || context_window(ctx),
        cost: cost || format_cost(ctx.cost)
      }
    end

    ##
    # @param [String] status
    # @return [Boolean]
    #  Returns true when the status represents an interruptible request.
    def cancellable?(status)
      text = status.to_s
      text.start_with?("Thinking", "Running", "Compacting")
    end

    ##
    # @param [Relay::Models::Context] ctx
    # @return [Hash]
    #  Returns the current context-window display payload.
    def context_window(ctx)
      if ctx.compacted?
        max = ctx.context_window || 0
        {used: 0, max:, label: "Context compacted"}
      else
        used = ctx.usage.total_tokens || 0
        max = ctx.context_window || 0
        {used:, max:, label: "#{used} / #{max} tokens"}
      end
    rescue LLM::NoSuchModelError, LLM::NoSuchRegistryError
      {used: 0, max: 0, label: "0 / 0 tokens"}
    end

    ##
    # @param [String] cost
    # @return [String]
    #  Returns the formatted cost string.
    def format_cost(cost)
      return "unknown" if cost == "unknown"
      "$#{cost}"
    rescue LLM::NoSuchModelError, LLM::NoSuchRegistryError
      "unknown"
    end

    ##
    # @param [LLM::Provider]
    # @return [String]
    def format_name(name)
      case name
      when :openai then "OpenAI"
      when :xai then "xAI"
      when :deepseek then "DeepSeek"
      else name.to_s.capitalize
      end
    end
  end
end
