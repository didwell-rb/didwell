# frozen_string_literal: true

module DIDRain
  module DID
    # A DID verification method containing a public key and metadata.
    class VerificationMethod
      # @!attribute id
      #   @return [String] DID URL identifying this verification method
      # @!attribute type
      #   @return [String] verification method type (e.g. "JsonWebKey2020")
      # @!attribute controller
      #   @return [String] DID of the controller
      # @!attribute verification_material
      #   @return [VerificationMaterial] the key material
      attr_accessor :id, :type, :controller, :verification_material

      # @param id [String] DID URL identifying this verification method
      # @param type [String] verification method type
      # @param controller [String] DID of the controller
      # @param verification_material [VerificationMaterial] the key material
      def initialize(id:, type:, controller:, verification_material:)
        @id = id
        @type = type
        @controller = controller
        @verification_material = verification_material
      end

      # Deserialize a VerificationMethod from a Hash.
      #
      # @param hash [Hash] W3C verification method hash
      # @return [VerificationMethod]
      def self.from_hash(hash)
        format, value =
          if hash.key?("publicKeyJwk")
            [VerificationMaterialFormat::JWK, hash["publicKeyJwk"]]
          elsif hash.key?("publicKeyMultibase")
            [VerificationMaterialFormat::MULTIBASE, hash["publicKeyMultibase"]]
          elsif hash.key?("publicKeyBase58")
            [VerificationMaterialFormat::BASE58, hash["publicKeyBase58"]]
          else
            [VerificationMaterialFormat::OTHER, nil]
          end

        new(
          id: hash["id"],
          type: hash["type"],
          controller: hash["controller"],
          verification_material: VerificationMaterial.new(format: format, value: value)
        )
      end

      # Serialize the verification method to a Hash.
      #
      # @return [Hash] W3C-conformant verification method hash
      def to_hash
        h = {
          "id" => @id,
          "type" => @type,
          "controller" => @controller
        }

        case @verification_material.format
        when VerificationMaterialFormat::JWK
          h["publicKeyJwk"] = @verification_material.value
        when VerificationMaterialFormat::MULTIBASE
          h["publicKeyMultibase"] = @verification_material.value
        when VerificationMaterialFormat::BASE58
          h["publicKeyBase58"] = @verification_material.value
        end

        h
      end
    end
  end
end
