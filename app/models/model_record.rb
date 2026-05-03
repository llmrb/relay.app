# frozen_string_literal: true

module Relay::Models
  class ModelRecord < Sequel::Model
    include Relay::Model
    plugin :validation_class_methods

    set_dataset :model_records

    validates_presence_of :provider
    validates_presence_of :model_id
    validates_presence_of :name
    validates_presence_of :synced_at

    ##
    # Refreshes model records for every configured provider.
    #
    # Each provider builder is initialized and then passed through
    # {refresh} to replace its persisted model rows.
    #
    # @return [void]
    def self.refresh_all
      Relay.providers.each do |_, provider|
        provider = provider.call
        insert!(provider)
      end
    end

    ##
    # Replaces all stored model metadata for a provider in one transaction.
    #
    # Existing rows for the provider are deleted before the new rows are
    # inserted. An empty provider model list clears the provider's stored
    # model metadata.
    #
    # @param [LLM::Provider] provider
    # @return [void]
    def self.refresh(provider)
      now = Time.now.utc
      db.transaction do
        where(provider:).delete
        models = provider.models.all.filter_map do
          next unless _1.chat?
          {
            provider: provider.name,
            model_id: _1.id,
            name: _1.name.to_s,
            data: JSON.dump(_1.to_h),
            synced_at: now,
            created_at: now,
            updated_at: now
          }
        end
        multi_insert(models) unless models.empty?
      end
    end

    ##
    # @return [Hash]
    #  Returns the parsed model metadata payload.
    def data
      @data ||= JSON.parse(self[:data])
    rescue JSON::ParserError
      {}
    end
  end
end
