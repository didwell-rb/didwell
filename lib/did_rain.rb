# frozen_string_literal: true

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "did_rain"       => "DIDRain",
  "did"            => "DID",
  "did_comm"       => "DIDComm",
  "jws_envelope"   => "JWSEnvelope",
  "jwe_envelope"   => "JWEEnvelope",
  "ecdh"           => "ECDH",
  "concat_kdf"     => "ConcatKDF",
)
loader.setup

require_relative "did_rain/version"

# Ruby toolkit for Decentralized Identifiers (DIDs) and DIDComm messaging.
#
# DIDRain provides a complete implementation of the DID and DIDComm v2 specifications,
# including message packing/unpacking with encryption, signing, and anonymous forwarding.
#
# @example Pack and unpack a plaintext message
#   message = DIDRain::DIDComm::Message.new(type: "https://example.com/hello", body: { "text" => "Hi" })
#   result = DIDRain::DIDComm.pack_plaintext(message, resolvers_config: config)
#   unpacked = DIDRain::DIDComm.unpack(result.packed_msg, resolvers_config: config)
module DIDRain
end
