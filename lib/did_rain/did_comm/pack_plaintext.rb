# frozen_string_literal: true

require "json"

module DIDRain
  module DIDComm
    # Packs a DIDComm message as plaintext JSON (no encryption or signing).
    module PackPlaintext
      # @!attribute packed_msg
      #   @return [String] the JSON-encoded plaintext message
      # @!attribute from_prior_issuer_kid
      #   @return [String, nil] key ID used to sign the from_prior JWT, if present
      Result = Data.define(:packed_msg, :from_prior_issuer_kid)

      # Pack a message as plaintext.
      #
      # @param message [Message, Hash] the DIDComm message
      # @param resolvers_config [ResolversConfig] DID and secrets resolvers
      # @return [Result]
      def self.call(message, resolvers_config:)
        msg_hash = message.is_a?(Message) ? message.to_hash : message

        from_prior_issuer_kid = FromPrior.pack(msg_hash, resolvers_config)
        packed_msg = JSON.generate(msg_hash)

        Result.new(packed_msg: packed_msg, from_prior_issuer_kid: from_prior_issuer_kid)
      end
    end
  end
end
