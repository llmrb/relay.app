# frozen_string_literal: true

class API::Models < API::Base
  ##
  # Returns the chat-capable models for the provider
  # @return [Array]
  def call
    [
      200,
      { "content-type" => "application/json" },
      [filter(llm.models.all).map { { id: _1.id, name: _1.name } }.to_json]
    ]
  end

  private

  def filter(models)
    models.select(&:chat?)
  end
end
