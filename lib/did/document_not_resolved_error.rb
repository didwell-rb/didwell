# frozen_string_literal: true

module DID
  class DocumentNotResolvedError < Error
    def initialize(did)
      super("DID `#{did}` is not found in DID resolver")
    end
  end
end
