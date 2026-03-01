# frozen_string_literal: true

module DIDRain
  module DIDComm
    # A DIDComm service endpoint descriptor with routing and accept metadata.
    class Service
      # @!attribute id
      #   @return [String] service identifier
      # @!attribute type
      #   @return [String] service type (default: "DIDCommMessaging")
      # @!attribute service_endpoint
      #   @return [String] URI of the service endpoint
      # @!attribute routing_keys
      #   @return [Array<String>] mediator routing key DIDs
      # @!attribute accept
      #   @return [Array<String>] accepted message profiles (e.g. "didcomm/v2")
      attr_accessor :id, :type, :service_endpoint, :routing_keys, :accept

      # @param id [String] service identifier
      # @param type [String] service type
      # @param service_endpoint [String] URI of the service endpoint
      # @param routing_keys [Array<String>] mediator routing key DIDs
      # @param accept [Array<String>] accepted message profiles
      def initialize(id:, type: "DIDCommMessaging", service_endpoint:, routing_keys: [], accept: [])
        @id = id
        @type = type
        @service_endpoint = service_endpoint
        @routing_keys = routing_keys || []
        @accept = accept || []
      end

      # Find a DIDComm service in a DID document.
      #
      # @param document [DID::Document] the DID document to search
      # @param service_id [String, nil] specific service ID to find; if nil, finds the first DIDCommMessaging service accepting didcomm/v2
      # @return [Service, nil] the matching service, or nil
      def self.find_in(document, service_id = nil)
        if service_id
          document.service.find { |s| s.id == service_id }
        else
          document.service.find { |s| s.type == "DIDCommMessaging" && (s.accept.empty? || s.accept.include?("didcomm/v2")) }
        end
      end
    end
  end
end
