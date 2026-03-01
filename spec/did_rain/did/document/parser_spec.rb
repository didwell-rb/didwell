# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe DID::Document::Parser do
  describe ".parse" do
    it "parses a minimal document with only id" do
      doc = described_class.parse("id" => "did:example:123")

      expect(doc.id).to eq("did:example:123")
      expect(doc.verification_method).to eq([])
      expect(doc.authentication).to eq([])
      expect(doc.service).to eq([])
      expect(doc.controller).to be_nil
      expect(doc.also_known_as).to be_nil
    end

    it "parses controller as a string" do
      doc = described_class.parse(
        "id" => "did:example:123",
        "controller" => "did:example:controller"
      )

      expect(doc.controller).to eq("did:example:controller")
    end

    it "parses controller as an array" do
      doc = described_class.parse(
        "id" => "did:example:123",
        "controller" => ["did:example:c1", "did:example:c2"]
      )

      expect(doc.controller).to eq(["did:example:c1", "did:example:c2"])
    end

    it "parses alsoKnownAs" do
      doc = described_class.parse(
        "id" => "did:example:123",
        "alsoKnownAs" => ["https://example.com/user", "did:example:alt"]
      )

      expect(doc.also_known_as).to eq(["https://example.com/user", "did:example:alt"])
    end

    it "parses verification methods with publicKeyJwk" do
      jwk = { "kty" => "OKP", "crv" => "Ed25519", "x" => "abc123" }
      doc = described_class.parse(
        "id" => "did:example:123",
        "verificationMethod" => [
          {
            "id" => "did:example:123#key-1",
            "type" => "JsonWebKey2020",
            "controller" => "did:example:123",
            "publicKeyJwk" => jwk
          }
        ]
      )

      expect(doc.verification_method.size).to eq(1)
      vm = doc.verification_method.first
      expect(vm.id).to eq("did:example:123#key-1")
      expect(vm.type).to eq("JsonWebKey2020")
      expect(vm.controller).to eq("did:example:123")
      expect(vm.verification_material.format).to eq(DID::VerificationMaterialFormat::JWK)
      expect(vm.verification_material.value).to eq(jwk)
    end

    it "parses verification methods with publicKeyMultibase" do
      doc = described_class.parse(
        "id" => "did:example:123",
        "verificationMethod" => [
          {
            "id" => "did:example:123#key-1",
            "type" => "Multikey",
            "controller" => "did:example:123",
            "publicKeyMultibase" => "z6Mkf5rGMoatrSj1f4CyvuHBeXJELe9RPdzo2PKGNCKVtZxP"
          }
        ]
      )

      vm = doc.verification_method.first
      expect(vm.verification_material.format).to eq(DID::VerificationMaterialFormat::MULTIBASE)
      expect(vm.verification_material.value).to eq("z6Mkf5rGMoatrSj1f4CyvuHBeXJELe9RPdzo2PKGNCKVtZxP")
    end

    it "parses verification methods with publicKeyBase58" do
      doc = described_class.parse(
        "id" => "did:example:123",
        "verificationMethod" => [
          {
            "id" => "did:example:123#key-1",
            "type" => "Ed25519VerificationKey2018",
            "controller" => "did:example:123",
            "publicKeyBase58" => "3M5RCDjHi5FQbiVB6p5ParVnLCLXfGmwEogjywRFDSga"
          }
        ]
      )

      vm = doc.verification_method.first
      expect(vm.verification_material.format).to eq(DID::VerificationMaterialFormat::BASE58)
      expect(vm.verification_material.value).to eq("3M5RCDjHi5FQbiVB6p5ParVnLCLXfGmwEogjywRFDSga")
    end

    it "parses verification relationships as string references" do
      doc = described_class.parse(
        "id" => "did:example:123",
        "verificationMethod" => [
          {
            "id" => "did:example:123#key-1",
            "type" => "JsonWebKey2020",
            "controller" => "did:example:123",
            "publicKeyJwk" => { "kty" => "OKP" }
          }
        ],
        "authentication" => ["did:example:123#key-1"],
        "assertionMethod" => ["did:example:123#key-1"]
      )

      expect(doc.authentication).to eq(["did:example:123#key-1"])
      expect(doc.assertion_method).to eq(["did:example:123#key-1"])
    end

    it "parses embedded verification methods in relationships" do
      embedded_vm = {
        "id" => "did:example:123#key-embedded",
        "type" => "JsonWebKey2020",
        "controller" => "did:example:123",
        "publicKeyJwk" => { "kty" => "OKP" }
      }

      doc = described_class.parse(
        "id" => "did:example:123",
        "authentication" => [embedded_vm]
      )

      expect(doc.authentication).to eq(["did:example:123#key-embedded"])
      expect(doc.verification_method.size).to eq(1)
      expect(doc.verification_method.first.id).to eq("did:example:123#key-embedded")
    end

    it "parses mixed string refs and embedded methods in relationships" do
      embedded_vm = {
        "id" => "did:example:123#key-embedded",
        "type" => "JsonWebKey2020",
        "controller" => "did:example:123",
        "publicKeyJwk" => { "kty" => "OKP" }
      }

      doc = described_class.parse(
        "id" => "did:example:123",
        "verificationMethod" => [
          {
            "id" => "did:example:123#key-1",
            "type" => "JsonWebKey2020",
            "controller" => "did:example:123",
            "publicKeyJwk" => { "kty" => "OKP" }
          }
        ],
        "authentication" => ["did:example:123#key-1", embedded_vm]
      )

      expect(doc.authentication).to eq(["did:example:123#key-1", "did:example:123#key-embedded"])
      expect(doc.verification_method.size).to eq(2)
    end

    it "parses all verification relationship types" do
      doc = described_class.parse(
        "id" => "did:example:123",
        "verificationMethod" => [
          {
            "id" => "did:example:123#key-1",
            "type" => "JsonWebKey2020",
            "controller" => "did:example:123",
            "publicKeyJwk" => { "kty" => "OKP" }
          }
        ],
        "authentication" => ["did:example:123#key-1"],
        "assertionMethod" => ["did:example:123#key-1"],
        "keyAgreement" => ["did:example:123#key-1"],
        "capabilityInvocation" => ["did:example:123#key-1"],
        "capabilityDelegation" => ["did:example:123#key-1"]
      )

      expect(doc.authentication).to eq(["did:example:123#key-1"])
      expect(doc.assertion_method).to eq(["did:example:123#key-1"])
      expect(doc.key_agreement).to eq(["did:example:123#key-1"])
      expect(doc.capability_invocation).to eq(["did:example:123#key-1"])
      expect(doc.capability_delegation).to eq(["did:example:123#key-1"])
    end

    it "parses services" do
      doc = described_class.parse(
        "id" => "did:example:123",
        "service" => [
          {
            "id" => "did:example:123#linked-domain",
            "type" => "LinkedDomains",
            "serviceEndpoint" => "https://example.com"
          }
        ]
      )

      expect(doc.service.size).to eq(1)
      svc = doc.service.first
      expect(svc).to be_a(DID::Service)
      expect(svc.id).to eq("did:example:123#linked-domain")
      expect(svc.type).to eq("LinkedDomains")
      expect(svc.service_endpoint).to eq("https://example.com")
    end

    it "parses a full document with all fields" do
      jwk = { "kty" => "OKP", "crv" => "Ed25519", "x" => "abc" }
      hash = {
        "id" => "did:example:alice",
        "controller" => "did:example:alice",
        "alsoKnownAs" => ["https://alice.example.com"],
        "verificationMethod" => [
          {
            "id" => "did:example:alice#key-1",
            "type" => "JsonWebKey2020",
            "controller" => "did:example:alice",
            "publicKeyJwk" => jwk
          }
        ],
        "authentication" => ["did:example:alice#key-1"],
        "assertionMethod" => ["did:example:alice#key-1"],
        "keyAgreement" => ["did:example:alice#key-1"],
        "capabilityInvocation" => ["did:example:alice#key-1"],
        "capabilityDelegation" => ["did:example:alice#key-1"],
        "service" => [
          {
            "id" => "did:example:alice#service-1",
            "type" => "LinkedDomains",
            "serviceEndpoint" => "https://alice.example.com"
          }
        ]
      }

      doc = described_class.parse(hash)

      expect(doc.id).to eq("did:example:alice")
      expect(doc.controller).to eq("did:example:alice")
      expect(doc.also_known_as).to eq(["https://alice.example.com"])
      expect(doc.verification_method.size).to eq(1)
      expect(doc.authentication).to eq(["did:example:alice#key-1"])
      expect(doc.service.size).to eq(1)
    end
  end

  describe ".parse_json" do
    it "parses a JSON string" do
      json = '{"id": "did:example:123"}'
      doc = described_class.parse_json(json)
      expect(doc.id).to eq("did:example:123")
    end
  end

  describe "validation" do
    it "raises on non-hash input" do
      expect { described_class.parse("not a hash") }
        .to raise_error(DID::InvalidDocumentError, /must be a Hash/)
    end

    it "raises when id is missing" do
      expect { described_class.parse({}) }
        .to raise_error(DID::InvalidDocumentError, /must have an 'id' field/)
    end

    it "raises when id is not a valid DID" do
      expect { described_class.parse("id" => "not-a-did") }
        .to raise_error(DID::InvalidDocumentError, /must be a valid DID/)
    end
  end
end
