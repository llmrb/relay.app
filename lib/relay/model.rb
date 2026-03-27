# frozen_string_literal: true

module Relay
  module Model
    def self.included(model)
      model.plugin :timestamps,
        create: :created_at,
        update: :updated_at,
        update_on_create: true
    end
  end
end
