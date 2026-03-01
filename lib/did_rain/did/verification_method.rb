# frozen_string_literal: true

module DIDRain
  module DID
    class VerificationMethod
      attr_accessor :id, :type, :controller, :verification_material

      def initialize(id:, type:, controller:, verification_material:)
        @id = id
        @type = type
        @controller = controller
        @verification_material = verification_material
      end

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
