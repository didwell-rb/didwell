# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe DIDRain::DID::Document::Renderer do
  let(:jwk) { { "kty" => "OKP", "crv" => "Ed25519", "x" => "abc" } }

  let(:vm) do
    DIDRain::DID::VerificationMethod.new(
      id: "did:example:123#key-1",
      type: DIDRain::DID::VerificationMethodType::JSON_WEB_KEY_2020,
      controller: "did:example:123",
      verification_material: DIDRain::DID::VerificationMaterial.new(
        format: DIDRain::DID::VerificationMaterialFormat::JWK,
        value: jwk
      )
    )
  end

  describe ".render" do
    it "renders a minimal document" do
      doc = DIDRain::DID::Document.new(id: "did:example:123")
      h = described_class.render(doc)

      expect(h).to eq("id" => "did:example:123")
    end

    it "omits empty optional fields" do
      doc = DIDRain::DID::Document.new(id: "did:example:123")
      h = described_class.render(doc)

      expect(h).not_to have_key("controller")
      expect(h).not_to have_key("alsoKnownAs")
      expect(h).not_to have_key("verificationMethod")
      expect(h).not_to have_key("authentication")
      expect(h).not_to have_key("assertionMethod")
      expect(h).not_to have_key("keyAgreement")
      expect(h).not_to have_key("capabilityInvocation")
      expect(h).not_to have_key("capabilityDelegation")
      expect(h).not_to have_key("service")
    end

    it "renders controller as a string" do
      doc = DIDRain::DID::Document.new(id: "did:example:123", controller: "did:example:ctrl")
      h = described_class.render(doc)

      expect(h["controller"]).to eq("did:example:ctrl")
    end

    it "renders controller as an array" do
      doc = DIDRain::DID::Document.new(id: "did:example:123", controller: ["did:example:c1", "did:example:c2"])
      h = described_class.render(doc)

      expect(h["controller"]).to eq(["did:example:c1", "did:example:c2"])
    end

    it "renders alsoKnownAs" do
      doc = DIDRain::DID::Document.new(id: "did:example:123", also_known_as: ["https://example.com"])
      h = described_class.render(doc)

      expect(h["alsoKnownAs"]).to eq(["https://example.com"])
    end

    it "renders verification methods" do
      doc = DIDRain::DID::Document.new(
        id: "did:example:123",
        verification_method: [vm]
      )
      h = described_class.render(doc)

      expect(h["verificationMethod"]).to eq([
        {
          "id" => "did:example:123#key-1",
          "type" => "JsonWebKey2020",
          "controller" => "did:example:123",
          "publicKeyJwk" => jwk
        }
      ])
    end

    it "renders verification relationships as string refs" do
      doc = DIDRain::DID::Document.new(
        id: "did:example:123",
        verification_method: [vm],
        authentication: ["did:example:123#key-1"],
        assertion_method: ["did:example:123#key-1"]
      )
      h = described_class.render(doc)

      expect(h["authentication"]).to eq(["did:example:123#key-1"])
      expect(h["assertionMethod"]).to eq(["did:example:123#key-1"])
    end

    it "renders services" do
      svc = DIDRain::DID::Service.new(
        id: "did:example:123#svc",
        type: "LinkedDomains",
        service_endpoint: "https://example.com"
      )
      doc = DIDRain::DID::Document.new(id: "did:example:123", service: [svc])
      h = described_class.render(doc)

      expect(h["service"]).to eq([
        {
          "id" => "did:example:123#svc",
          "type" => "LinkedDomains",
          "serviceEndpoint" => "https://example.com"
        }
      ])
    end

    it "renders a full document" do
      svc = DIDRain::DID::Service.new(
        id: "did:example:123#svc",
        type: "LinkedDomains",
        service_endpoint: "https://example.com"
      )
      doc = DIDRain::DID::Document.new(
        id: "did:example:123",
        controller: "did:example:123",
        also_known_as: ["https://example.com/user"],
        verification_method: [vm],
        authentication: ["did:example:123#key-1"],
        assertion_method: ["did:example:123#key-1"],
        key_agreement: ["did:example:123#key-1"],
        capability_invocation: ["did:example:123#key-1"],
        capability_delegation: ["did:example:123#key-1"],
        service: [svc]
      )
      h = described_class.render(doc)

      expect(h["id"]).to eq("did:example:123")
      expect(h["controller"]).to eq("did:example:123")
      expect(h["alsoKnownAs"]).to eq(["https://example.com/user"])
      expect(h.keys).to include(
        "verificationMethod", "authentication", "assertionMethod",
        "keyAgreement", "capabilityInvocation", "capabilityDelegation", "service"
      )
    end
  end

  describe ".render_json" do
    it "returns a JSON string" do
      doc = DIDRain::DID::Document.new(id: "did:example:123")
      json = described_class.render_json(doc)
      parsed = JSON.parse(json)

      expect(parsed["id"]).to eq("did:example:123")
    end
  end

  describe "round-trip" do
    it "parse → render → parse produces equivalent documents" do
      original_hash = {
        "id" => "did:example:roundtrip",
        "controller" => "did:example:roundtrip",
        "alsoKnownAs" => ["https://example.com/rt"],
        "verificationMethod" => [
          {
            "id" => "did:example:roundtrip#key-1",
            "type" => "JsonWebKey2020",
            "controller" => "did:example:roundtrip",
            "publicKeyJwk" => { "kty" => "OKP", "crv" => "Ed25519", "x" => "test" }
          }
        ],
        "authentication" => ["did:example:roundtrip#key-1"],
        "assertionMethod" => ["did:example:roundtrip#key-1"],
        "service" => [
          {
            "id" => "did:example:roundtrip#svc",
            "type" => "LinkedDomains",
            "serviceEndpoint" => "https://example.com"
          }
        ]
      }

      doc1 = DIDRain::DID::Document::Parser.parse(original_hash)
      rendered = DIDRain::DID::Document::Renderer.render(doc1)
      doc2 = DIDRain::DID::Document::Parser.parse(rendered)

      expect(doc2.id).to eq(doc1.id)
      expect(doc2.controller).to eq(doc1.controller)
      expect(doc2.also_known_as).to eq(doc1.also_known_as)
      expect(doc2.verification_method.size).to eq(doc1.verification_method.size)
      expect(doc2.authentication).to eq(doc1.authentication)
      expect(doc2.assertion_method).to eq(doc1.assertion_method)
      expect(doc2.service.size).to eq(doc1.service.size)
    end

    it "render → parse → render produces equivalent hashes" do
      svc = DIDRain::DID::Service.new(
        id: "did:example:rt#svc",
        type: "LinkedDomains",
        service_endpoint: "https://example.com"
      )
      doc = DIDRain::DID::Document.new(
        id: "did:example:rt",
        controller: ["did:example:c1"],
        also_known_as: ["https://example.com"],
        verification_method: [vm],
        authentication: ["did:example:123#key-1"],
        service: [svc]
      )

      h1 = DIDRain::DID::Document::Renderer.render(doc)
      doc2 = DIDRain::DID::Document::Parser.parse(h1)
      h2 = DIDRain::DID::Document::Renderer.render(doc2)

      expect(h2).to eq(h1)
    end
  end
end
