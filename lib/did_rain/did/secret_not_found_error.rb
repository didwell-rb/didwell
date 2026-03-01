# frozen_string_literal: true

module DIDRain
  module DID
    # Raised when a required private key (secret) cannot be found.
    class SecretNotFoundError < Error; end
  end
end
