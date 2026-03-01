# frozen_string_literal: true

module DIDRain
  module DIDComm
    # Configuration holding the DID and secrets resolvers needed for pack/unpack operations.
    #
    # @!attribute did_resolver
    #   @return [DID::Resolver] resolver for DID documents
    # @!attribute secrets_resolver
    #   @return [DID::SecretsResolver] resolver for private keys
    ResolversConfig = Data.define(:did_resolver, :secrets_resolver)
  end
end
