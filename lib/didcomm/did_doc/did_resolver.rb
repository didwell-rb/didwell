# frozen_string_literal: true

module DIDComm
  module DIDResolver
    def resolve(did)
      raise NotImplementedError, "#{self.class}#resolve must be implemented"
    end
  end
end
