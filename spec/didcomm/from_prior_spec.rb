# frozen_string_literal: true

require "spec_helper"

RSpec.describe "FromPrior" do
  let(:resolvers_alice) { TestVectors.resolvers_config_alice }
  let(:resolvers_bob) { TestVectors.resolvers_config_bob }
  let(:resolvers_charlie) { TestVectors.resolvers_config_charlie }

  describe DIDComm::FromPrior do
    it "serializes and deserializes" do
      fp = DIDComm::FromPrior.new(
        iss: "did:example:charlie",
        sub: "did:example:alice",
        aud: "test", exp: 100, nbf: 50, iat: 1, jti: "jwt-id"
      )
      h = fp.to_hash
      expect(h["iss"]).to eq("did:example:charlie")
      expect(h["sub"]).to eq("did:example:alice")

      parsed = DIDComm::FromPrior.from_hash(h)
      expect(parsed.iss).to eq("did:example:charlie")
      expect(parsed.jti).to eq("jwt-id")
    end
  end

  describe "from_prior pack/unpack in message" do
    it "packs and unpacks from_prior JWT in plaintext" do
      msg = DIDComm::Message.new(
        id: "test-fp",
        type: "http://example.com/test",
        from: "did:example:alice",
        to: ["did:example:bob"],
        body: { "test" => true },
        from_prior: DIDComm::FromPrior.new(
          iss: "did:example:charlie",
          sub: "did:example:alice"
        )
      )

      # Pack plaintext - from_prior should be JWT string
      msg_hash = msg.to_hash
      kid = DIDComm::FromPriorModule.pack_from_prior(msg_hash, resolvers_charlie)
      expect(kid).to eq("did:example:charlie#key-1")
      expect(msg_hash["from_prior"]).to be_a(String)
      expect(msg_hash["from_prior"].split(".").length).to eq(3)

      # Unpack
      issuer_kid = DIDComm::FromPriorModule.unpack_from_prior(msg_hash, resolvers_bob)
      expect(issuer_kid).to eq("did:example:charlie#key-1")
      expect(msg_hash["from_prior"]).to be_a(Hash)
      expect(msg_hash["from_prior"]["iss"]).to eq("did:example:charlie")
      expect(msg_hash["from_prior"]["sub"]).to eq("did:example:alice")
    end
  end
end
