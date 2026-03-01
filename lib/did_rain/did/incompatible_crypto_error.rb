# frozen_string_literal: true

module DIDRain
  module DID
    # Raised when sender and recipient keys are cryptographically incompatible.
    class IncompatibleCryptoError < Error
      # @param msg [String, nil] optional custom error message
      def initialize(msg = nil)
        super(msg || "Sender and recipient keys corresponding to provided parameters are incompatible to each other")
      end
    end
  end
end
