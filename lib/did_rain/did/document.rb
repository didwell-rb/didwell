# frozen_string_literal: true

module DIDRain
  module DID
    class Document
      attr_accessor :id, :controller, :also_known_as,
                    :authentication, :key_agreement, :assertion_method,
                    :capability_invocation, :capability_delegation,
                    :verification_method, :service

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

      def get_verification_method(kid)
        @verification_method.find { |vm| vm.id == kid }
      end

      def authentication_methods
        @verification_method.select { |vm| @authentication.include?(vm.id) }
      end

      def key_agreement_methods
        @verification_method.select { |vm| @key_agreement.include?(vm.id) }
      end
    end
  end
end
