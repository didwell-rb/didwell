# frozen_string_literal: true

module DIDRain
  module DIDComm
    # Raised when a DIDComm message is malformed, such as invalid plaintext,
    # bad signatures, or decryption failures.
    class MalformedMessageError < Error
      # @return [Symbol] error code identifying the failure category
      attr_reader :code

      # Symbolic error codes mapped to numeric identifiers.
      CODES = {
        can_not_decrypt: 1,
        invalid_signature: 2,
        invalid_plaintext: 3,
        invalid_message: 4,
        not_supported_fwd_protocol: 5
      }.freeze

      DEFAULT_MESSAGES = {
        can_not_decrypt: "DIDComm message cannot be decrypted",
        invalid_signature: "Signature is invalid",
        invalid_plaintext: "Plaintext is invalid",
        invalid_message: "DIDComm message is invalid",
        not_supported_fwd_protocol: "Not supported Forward protocol"
      }.freeze

      # @param code [Symbol] error code (e.g. :invalid_plaintext, :can_not_decrypt)
      # @param message [String, nil] optional custom error message
      def initialize(code, message = nil)
        @code = code
        super(message || DEFAULT_MESSAGES[code] || "Unknown error")
      end
    end
  end
end
