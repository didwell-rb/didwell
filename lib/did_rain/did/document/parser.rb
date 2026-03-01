# frozen_string_literal: true

require "json"

module DIDRain
  module DID
    class Document
      class Parser
        RELATIONSHIP_KEYS = {
          "authentication" => :authentication,
          "assertionMethod" => :assertion_method,
          "keyAgreement" => :key_agreement,
          "capabilityInvocation" => :capability_invocation,
          "capabilityDelegation" => :capability_delegation
        }.freeze

        def self.parse_json(json_str)
          parse(JSON.parse(json_str))
        end

        def self.parse(hash)
          validate!(hash)

          verification_methods = (hash["verificationMethod"] || []).map do |vm|
            VerificationMethod.from_hash(vm)
          end

          relationships = {}
          RELATIONSHIP_KEYS.each do |json_key, attr_key|
            refs, embedded = parse_relationship(hash[json_key])
            verification_methods.concat(embedded)
            relationships[attr_key] = refs
          end

          services = (hash["service"] || []).map do |s|
            DID::Service.from_hash(s)
          end

          controller = hash["controller"]
          also_known_as = hash["alsoKnownAs"]

          Document.new(
            id: hash["id"],
            controller: controller,
            also_known_as: also_known_as,
            verification_method: verification_methods,
            authentication: relationships[:authentication],
            assertion_method: relationships[:assertion_method],
            key_agreement: relationships[:key_agreement],
            capability_invocation: relationships[:capability_invocation],
            capability_delegation: relationships[:capability_delegation],
            service: services
          )
        end

        def self.validate!(hash)
          raise InvalidDocumentError, "DID Document must be a Hash" unless hash.is_a?(Hash)
          raise InvalidDocumentError, "DID Document must have an 'id' field" unless hash.key?("id")
          raise InvalidDocumentError, "DID Document 'id' must be a valid DID" unless Utils.is_did(hash["id"])
        end

        def self.parse_relationship(entries)
          return [[], []] if entries.nil?

          refs = []
          embedded = []

          entries.each do |entry|
            if entry.is_a?(String)
              refs << entry
            elsif entry.is_a?(Hash)
              vm = VerificationMethod.from_hash(entry)
              embedded << vm
              refs << vm.id
            end
          end

          [refs, embedded]
        end

        private_class_method :validate!, :parse_relationship
      end
    end
  end
end
