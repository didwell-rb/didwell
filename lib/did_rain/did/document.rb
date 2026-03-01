# frozen_string_literal: true

module DIDRain
  module DID
    # A W3C DID Document containing verification methods, services, and
    # verification relationships.
    #
    # @see https://www.w3.org/TR/did-core/ W3C DID Core Specification
    class Document
      # @!attribute id
      #   @return [String] the DID subject identifier
      # @!attribute controller
      #   @return [String, Array<String>, nil] DID(s) authorized to make changes
      # @!attribute also_known_as
      #   @return [Array<String>, nil] alternative identifiers
      # @!attribute authentication
      #   @return [Array<String>] verification method IDs for authentication
      # @!attribute key_agreement
      #   @return [Array<String>] verification method IDs for key agreement
      # @!attribute assertion_method
      #   @return [Array<String>] verification method IDs for assertions
      # @!attribute capability_invocation
      #   @return [Array<String>] verification method IDs for capability invocation
      # @!attribute capability_delegation
      #   @return [Array<String>] verification method IDs for capability delegation
      # @!attribute verification_method
      #   @return [Array<VerificationMethod>] verification methods in this document
      # @!attribute service
      #   @return [Array<Service>] service endpoints
      attr_accessor :id, :controller, :also_known_as,
                    :authentication, :key_agreement, :assertion_method,
                    :capability_invocation, :capability_delegation,
                    :verification_method, :service

      # @param id [String] the DID subject identifier
      # @param controller [String, Array<String>, nil] DID(s) authorized to make changes
      # @param also_known_as [Array<String>, nil] alternative identifiers
      # @param authentication [Array<String>] authentication relationship IDs
      # @param key_agreement [Array<String>] key agreement relationship IDs
      # @param assertion_method [Array<String>] assertion method relationship IDs
      # @param capability_invocation [Array<String>] capability invocation relationship IDs
      # @param capability_delegation [Array<String>] capability delegation relationship IDs
      # @param verification_method [Array<VerificationMethod>] verification methods
      # @param service [Array<Service>] service endpoints
      def initialize(id:, controller: nil, also_known_as: nil,
                     authentication: [], key_agreement: [], assertion_method: [],
                     capability_invocation: [], capability_delegation: [],
                     verification_method: [], service: [])
        @id = id
        @controller = controller
        @also_known_as = also_known_as
        @authentication = authentication || []
        @key_agreement = key_agreement || []
        @assertion_method = assertion_method || []
        @capability_invocation = capability_invocation || []
        @capability_delegation = capability_delegation || []
        @verification_method = verification_method || []
        @service = service || []
      end

      # Find a verification method by its key ID.
      #
      # @param kid [String] the verification method ID (DID URL)
      # @return [VerificationMethod, nil] the matching method, or nil
      def get_verification_method(kid)
        @verification_method.find { |vm| vm.id == kid }
      end

      # Return verification methods referenced by the authentication relationship.
      #
      # @return [Array<VerificationMethod>]
      def authentication_methods
        @verification_method.select { |vm| @authentication.include?(vm.id) }
      end

      # Return verification methods referenced by the key agreement relationship.
      #
      # @return [Array<VerificationMethod>]
      def key_agreement_methods
        @verification_method.select { |vm| @key_agreement.include?(vm.id) }
      end
    end
  end
end
