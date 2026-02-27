# frozen_string_literal: true

module DIDComm
  class SecretsResolverInMemory
    include SecretsResolver

    def initialize(secrets)
      @secrets = {}
      secrets.each { |s| @secrets[s.kid] = s }
    end

    def get_key(kid)
      @secrets[kid]
    end

    def get_keys(kids)
      @secrets.values.select { |s| kids.include?(s.kid) }.map(&:kid)
    end
  end
end
