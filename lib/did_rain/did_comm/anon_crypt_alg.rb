# frozen_string_literal: true

module DIDRain
  module DIDComm
    # Anonymous encryption algorithm constants (ECDH-ES key agreement).
    module AnonCryptAlg
      # AES-256-CBC with HMAC-SHA-512
      A256CBC_HS512_ECDH_ES_A256KW = Algs.new(alg: "ECDH-ES+A256KW", enc: "A256CBC-HS512").freeze
      # XChaCha20-Poly1305
      XC20P_ECDH_ES_A256KW = Algs.new(alg: "ECDH-ES+A256KW", enc: "XC20P").freeze
      # AES-256-GCM
      A256GCM_ECDH_ES_A256KW = Algs.new(alg: "ECDH-ES+A256KW", enc: "A256GCM").freeze

      # @return [Array<Algs>] all supported anonymous encryption algorithms
      ALL = [A256CBC_HS512_ECDH_ES_A256KW, XC20P_ECDH_ES_A256KW, A256GCM_ECDH_ES_A256KW].freeze

      # Look up an anonymous encryption algorithm by its content encryption identifier.
      #
      # @param enc [String] content encryption algorithm name (e.g. "XC20P")
      # @return [Algs, nil] the matching algorithm, or nil
      def self.by_enc(enc)
        ALL.find { |a| a.enc == enc }
      end
    end
  end
end
