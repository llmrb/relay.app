# frozen_string_literal: true

module Tool
  class CreateImage < LLM::Tool
    name "create-image"
    description "Create a generated image"
    param :prompt, String, "The prompt", required: true
    param :provider, Enum["openai", "gemini", "xai"], "The provider", default: "gemini"

    ##
    # Returns a HTML link for an image
    # @return [Hash]
    def call(prompt:, provider: "gemini")
      file = "#{SecureRandom.hex}.png"
      key  = ENV["#{provider.upcase}_SECRET"]
      llm  = LLM.method(provider).call(key:)
      res  = llm.images.create(prompt:)
      IO.copy_stream res.images[0], File.join(images_dir, file)
      { directions: 'embed the html in your response exactly as it appears', html: "<img src='/g/#{file}'>" }
    rescue LLM::RateLimitError => ex
      { error: ex.class.to_s, message: "rate limit reached" }
    rescue => ex
      { error: ex.class.to_s, message: ex.message }
    end

    private

    def project_root = File.realpath(File.join(__dir__, "..", ".."))
    def images_dir = File.join(project_root, "public", "g")
  end
end
