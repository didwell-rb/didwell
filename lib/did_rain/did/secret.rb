# frozen_string_literal: true

module DIDRain
  module DID
    # A private key (secret) associated with a DID verification method.
    class Secret
      # @!attribute kid
      #   @return [String] key ID (DID URL) identifying this secret
      # @!attribute type
      #   @return [String] verification method type
      # @!attribute verification_material
      #   @return [VerificationMaterial] the private key material
      attr_accessor :kid, :type, :verification_material

      # @param kid [String] key ID (DID URL)
      # @param type [String] verification method type
      # @param verification_material [VerificationMaterial] the private key material
      def initialize(kid:, type:, verification_material:)
        @kid = kid
        @type = type
        @verification_material = verification_material
      end
    end
  end
end
