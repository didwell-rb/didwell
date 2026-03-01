# frozen_string_literal: true

module DIDRain
  module DID
    class Service
      attr_accessor :id, :type, :service_endpoint

      def initialize(id:, type:, service_endpoint:)
        @id = id
        @type = type
        @service_endpoint = service_endpoint
      end

      def self.from_hash(hash)
        new(
          id: hash["id"],
          type: hash["type"],
          service_endpoint: hash["serviceEndpoint"]
        )
      end

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
