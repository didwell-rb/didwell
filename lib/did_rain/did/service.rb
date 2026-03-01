# frozen_string_literal: true

module DIDRain
  module DID
    # A DID Document service endpoint.
    class Service
      # @!attribute id
      #   @return [String] service identifier
      # @!attribute type
      #   @return [String] service type
      # @!attribute service_endpoint
      #   @return [String, Hash, Array] service endpoint URI or structure
      attr_accessor :id, :type, :service_endpoint

      # @param id [String] service identifier
      # @param type [String] service type
      # @param service_endpoint [String, Hash, Array] service endpoint URI or structure
      def initialize(id:, type:, service_endpoint:)
        @id = id
        @type = type
        @service_endpoint = service_endpoint
      end

      # Deserialize a Service from a Hash.
      #
      # @param hash [Hash] W3C service hash with "id", "type", "serviceEndpoint" keys
      # @return [Service]
      def self.from_hash(hash)
        new(
          id: hash["id"],
          type: hash["type"],
          service_endpoint: hash["serviceEndpoint"]
        )
      end

      # Serialize the service to a Hash.
      #
      # @return [Hash] W3C-conformant service hash
      def to_hash
        {
          "id" => @id,
          "type" => @type,
          "serviceEndpoint" => @service_endpoint
        }
      end
    end
  end
end
