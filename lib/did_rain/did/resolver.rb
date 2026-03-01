# frozen_string_literal: true

module DIDRain
  module DID
    # Interface for DID document resolution. Include this module and implement {#resolve}.
    module Resolver
      # Resolve a DID to its DID Document.
      #
      # @param did [String] the DID to resolve
      # @return [Document, nil] the resolved document, or nil if not found
      # @raise [NotImplementedError] if not overridden
      def resolve(did)
        raise NotImplementedError, "#{self.class}#resolve must be implemented"
      end
    end
  end
end
