# frozen_string_literal: true

module Relay::Models
  class User < Sequel::Model
    set_dataset :users

    include Relay::Model

    one_to_many :contexts

    ##
    # Hashes and stores the given password.
    # @param [String] value
    def password=(value)
      @password = value
      self.password_digest = BCrypt::Password.create(value)
    end

    ##
    # Authenticates the given plaintext password.
    # @param [String] value
    # @return [Relay::Models::User,false]
    def authenticate(value)
      return false if password_digest.to_s.empty?

      BCrypt::Password.new(password_digest) == value && self
    rescue BCrypt::Errors::InvalidHash
      false
    end
  end
end
