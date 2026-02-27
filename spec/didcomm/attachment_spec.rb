# frozen_string_literal: true

require "spec_helper"

RSpec.describe DIDComm::Attachment do
  it "round-trips Base64 attachment" do
    a = DIDComm::Attachment.new(
      data: DIDComm::AttachmentDataBase64.new(base64: "dGVzdA=="),
      id: "att-1", description: "test attachment"
    )
    h = a.to_hash
    expect(h["data"]["base64"]).to eq("dGVzdA==")

    parsed = DIDComm::Attachment.from_hash(h)
    expect(parsed.data).to be_a(DIDComm::AttachmentDataBase64)
    expect(parsed.data.base64).to eq("dGVzdA==")
    expect(parsed.description).to eq("test attachment")
  end

  it "round-trips JSON attachment" do
    a = DIDComm::Attachment.new(
      data: DIDComm::AttachmentDataJson.new(json: { "key" => "value" })
    )
    h = a.to_hash
    parsed = DIDComm::Attachment.from_hash(h)
    expect(parsed.data).to be_a(DIDComm::AttachmentDataJson)
    expect(parsed.data.json).to eq({ "key" => "value" })
  end

  it "round-trips Links attachment" do
    a = DIDComm::Attachment.new(
      data: DIDComm::AttachmentDataLinks.new(
        links: ["https://example.com/file"],
        hash: "abc123"
      )
    )
    h = a.to_hash
    parsed = DIDComm::Attachment.from_hash(h)
    expect(parsed.data).to be_a(DIDComm::AttachmentDataLinks)
    expect(parsed.data.links).to eq(["https://example.com/file"])
  end

  it "includes message with attachments" do
    msg = DIDComm::Message.new(
      type: "test", body: {},
      attachments: [
        DIDComm::Attachment.new(
          id: "123",
          data: DIDComm::AttachmentDataBase64.new(base64: "qwerty"),
          description: "abc",
          filename: "test.txt",
          media_type: "text/plain",
          format: "text",
          lastmod_time: 123,
          byte_count: 6
        )
      ]
    )
    h = msg.to_hash
    expect(h["attachments"].length).to eq(1)
    expect(h["attachments"][0]["data"]["base64"]).to eq("qwerty")
    expect(h["attachments"][0]["id"]).to eq("123")

    parsed = DIDComm::Message.from_hash(h)
    expect(parsed.attachments.length).to eq(1)
    expect(parsed.attachments[0].data.base64).to eq("qwerty")
  end
end
