# frozen_string_literal: true

require "json"

module DIDRain
  module DID
    class Document
      # Renders a {Document} instance into a W3C-conformant Hash or JSON string.
      class Renderer
        # Render a DID Document as a JSON string.
        #
        # @param document [Document] the document to render
        # @return [String] JSON-encoded DID Document
        def self.render_json(document)
          JSON.generate(render(document))
        end

        # Render a DID Document as a Hash.
        #
        # @param document [Document] the document to render
        # @return [Hash] W3C-conformant DID Document hash
        def self.render(document)
          h = { "id" => document.id }

          h["controller"] = document.controller if document.controller
          h["alsoKnownAs"] = document.also_known_as if document.also_known_as

          unless document.verification_method.empty?
            h["verificationMethod"] = document.verification_method.map(&:to_hash)
          end

          render_relationship(h, "authentication", document.authentication)
          render_relationship(h, "assertionMethod", document.assertion_method)
          render_relationship(h, "keyAgreement", document.key_agreement)
          render_relationship(h, "capabilityInvocation", document.capability_invocation)
          render_relationship(h, "capabilityDelegation", document.capability_delegation)

          unless document.service.empty?
            h["service"] = document.service.map(&:to_hash)
          end

          h
        end

        def self.render_relationship(hash, key, refs)
          return if refs.empty?

          hash[key] = refs
        end

        private_class_method :render_relationship
      end
    end
  end
end
