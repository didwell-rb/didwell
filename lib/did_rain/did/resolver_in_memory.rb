# frozen_string_literal: true

module DIDRain
  module DID
    # An in-memory DID resolver backed by a pre-loaded collection of DID Documents.
    class ResolverInMemory
      include Resolver

      # @param did_docs [Array<Document>] the DID Documents to serve
      def initialize(did_docs)
        @did_docs = {}
        did_docs.each { |doc| @did_docs[doc.id] = doc }
      end

      # @param did [String] the DID to resolve
      # @return [Document, nil] the matching document, or nil
      def resolve(did)
        @did_docs[did]
      end
    end
  end
end
