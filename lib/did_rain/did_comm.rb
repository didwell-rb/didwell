# frozen_string_literal: true

module DIDRain
  # DIDComm v2 messaging: pack and unpack messages with plaintext, signed,
  # or encrypted envelopes per the DIDComm specification.
  module DIDComm
    # Pack a message as plaintext (no encryption or signing).
    #
    # @param message [Message, Hash] the DIDComm message to pack
    # @param resolvers_config [ResolversConfig] DID and secrets resolvers
    # @return [PackPlaintext::Result] the packed message and metadata
    def self.pack_plaintext(message, resolvers_config:)
      PackPlaintext.call(message, resolvers_config:)
    end

    # Pack a message with a non-repudiable signature.
    #
    # @param message [Message, Hash] the DIDComm message to pack
    # @param sign_from [String] DID or DID URL of the signer
    # @param resolvers_config [ResolversConfig] DID and secrets resolvers
    # @return [PackSigned::Result] the packed message and metadata
    # @raise [ValueError] if sign_from is not a valid DID
    def self.pack_signed(message, sign_from:, resolvers_config:)
      PackSigned.call(message, sign_from:, resolvers_config:)
    end

    # Pack a message with encryption (and optional signing).
    #
    # @param message [Message, Hash] the DIDComm message to pack
    # @param to [String] DID or DID URL of the recipient
    # @param from [String, nil] DID or DID URL of the sender for authenticated encryption
    # @param sign_from [String, nil] DID or DID URL of the signer for non-repudiation
    # @param resolvers_config [ResolversConfig] DID and secrets resolvers
    # @param pack_config [PackEncrypted::Config, nil] encryption options
    # @return [PackEncrypted::Result] the packed message and metadata
    # @raise [ValueError] if to, from, or sign_from are not valid DIDs
    def self.pack_encrypted(message, to:, from: nil, sign_from: nil, resolvers_config:, pack_config: nil)
      PackEncrypted.call(message, to:, from:, sign_from:, resolvers_config:, pack_config:)
    end

    # Unpack a DIDComm message, automatically detecting the envelope type.
    #
    # @param packed_msg [String, Hash] the packed message (JSON string or parsed Hash)
    # @param resolvers_config [ResolversConfig] DID and secrets resolvers
    # @param unpack_config [Unpack::Config, nil] unpacking options
    # @return [Unpack::Result] the unpacked message and metadata
    # @raise [MalformedMessageError] if the message is malformed
    def self.unpack(packed_msg, resolvers_config:, unpack_config: nil)
      Unpack.call(packed_msg, resolvers_config:, config: unpack_config)
    end
  end
end
