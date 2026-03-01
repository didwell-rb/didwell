# frozen_string_literal: true

module DIDRain
  module DIDComm
    # Authenticated encryption algorithm constants (ECDH-1PU key agreement).
    module AuthCryptAlg
      # AES-256-CBC with HMAC-SHA-512 using ECDH-1PU key agreement
      A256CBC_HS512_ECDH_1PU_A256KW = Algs.new(alg: "ECDH-1PU+A256KW", enc: "A256CBC-HS512").freeze

      # @return [Array<Algs>] all supported authenticated encryption algorithms
      ALL = [A256CBC_HS512_ECDH_1PU_A256KW].freeze

      # Look up an authenticated encryption algorithm by its content encryption identifier.
      #
      # @param enc [String] content encryption algorithm name
      # @return [Algs, nil] the matching algorithm, or nil
      def self.by_enc(enc)
        ALL.find { |a| a.enc == enc }
      end
    end
  end
end
