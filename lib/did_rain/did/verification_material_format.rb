# frozen_string_literal: true

module DIDRain
  module DID
    # Constants identifying the serialization format of key material.
    module VerificationMaterialFormat
      # JSON Web Key format
      JWK = :jwk
      # Base58 encoding
      BASE58 = :base58
      # Multibase encoding
      MULTIBASE = :multibase
      # Unknown or unsupported format
      OTHER = :other
    end
  end
end
