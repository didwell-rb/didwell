# frozen_string_literal: true

module DIDRain
  module DID
    # Raised when a DID cannot be resolved to a document.
    class DocumentNotResolvedError < Error
      # @param did [String] the DID that could not be resolved
      def initialize(did)
        super("DID `#{did}` is not found in DID resolver")
      end
    end
  end
end
