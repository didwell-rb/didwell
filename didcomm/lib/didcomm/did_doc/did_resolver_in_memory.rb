# frozen_string_literal: true

module DIDComm
  class DIDResolverInMemory
    include DIDResolver

    def initialize(did_docs)
      @did_docs = {}
      did_docs.each { |doc| @did_docs[doc.id] = doc }
    end

    def resolve(did)
      @did_docs[did]
    end
  end
end
