# frozen_string_literal: true

module DIDRain
  module DID
    # An in-memory secrets resolver backed by a pre-loaded collection of secrets.
    class SecretsResolverInMemory
      include SecretsResolver

      # @param secrets [Array<Secret>] the secrets to serve
      def initialize(secrets)
        @secrets = {}
        secrets.each { |s| @secrets[s.kid] = s }
      end

      # @param kid [String] the key ID (DID URL)
      # @return [Secret, nil] the secret, or nil if not found
      def get_key(kid)
        @secrets[kid]
      end

      # @param kids [Array<String>] key IDs to check
      # @return [Array<String>] key IDs that have available secrets
      def get_keys(kids)
        kids.select { |kid| @secrets.key?(kid) }
      end
    end
  end
end
