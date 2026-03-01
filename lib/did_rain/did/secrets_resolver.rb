# frozen_string_literal: true

module DIDRain
  module DID
    # Interface for resolving private keys (secrets). Include this module and
    # implement {#get_key} and {#get_keys}.
    module SecretsResolver
      # Retrieve a single secret by key ID.
      #
      # @param kid [String] the key ID (DID URL)
      # @return [Secret, nil] the secret, or nil if not found
      # @raise [NotImplementedError] if not overridden
      def get_key(kid)
        raise NotImplementedError, "#{self.class}#get_key must be implemented"
      end

      # Filter a list of key IDs to those that have known secrets.
      #
      # @param kids [Array<String>] key IDs to check
      # @return [Array<String>] the subset of key IDs that have available secrets
      # @raise [NotImplementedError] if not overridden
      def get_keys(kids)
        raise NotImplementedError, "#{self.class}#get_keys must be implemented"
      end
    end
  end
end
