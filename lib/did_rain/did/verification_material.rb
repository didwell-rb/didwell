# frozen_string_literal: true

module DIDRain
  module DID
    # Holds the key material for a verification method.
    #
    # @!attribute format
    #   @return [Symbol] the key format (see {VerificationMaterialFormat})
    # @!attribute value
    #   @return [Hash, String, nil] the key value (JWK hash, multibase string, etc.)
    VerificationMaterial = Data.define(:format, :value)
  end
end
