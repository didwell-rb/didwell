# frozen_string_literal: true

module DIDRain
  module DIDComm
    # IANA media type constants for DIDComm message envelopes.
    module MessageTypes
      # Encrypted message media type
      ENCRYPTED = "application/didcomm-encrypted+json"
      # Encrypted message media type (short form)
      ENCRYPTED_SHORT = "didcomm-encrypted+json"
      # Signed message media type
      SIGNED = "application/didcomm-signed+json"
      # Signed message media type (short form)
      SIGNED_SHORT = "didcomm-signed+json"
      # Plaintext message media type
      PLAINTEXT = "application/didcomm-plain+json"
      # Plaintext message media type (short form)
      PLAINTEXT_SHORT = "didcomm-plain+json"
    end
  end
end
