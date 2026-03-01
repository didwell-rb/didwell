# frozen_string_literal: true

module DIDRain
  module DIDComm
    # Signing algorithm constants for DIDComm JWS envelopes.
    module SignAlg
      # EdDSA with Ed25519 curve
      ED25519 = "EdDSA"
      # ECDSA with P-256 curve
      ES256 = "ES256"
      # ECDSA with secp256k1 curve
      ES256K = "ES256K"
    end
  end
end
