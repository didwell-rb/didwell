# frozen_string_literal: true

module DIDRain
  module DIDComm
    # An algorithm pair identifying a JWE key-wrapping algorithm and content encryption algorithm.
    #
    # @!attribute alg
    #   @return [String] JWE key-wrapping algorithm (e.g. "ECDH-ES+A256KW")
    # @!attribute enc
    #   @return [String] JWE content encryption algorithm (e.g. "A256CBC-HS512")
    Algs = Data.define(:alg, :enc)
  end
end
