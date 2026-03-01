# frozen_string_literal: true

require "securerandom"

module DIDRain
  module DIDComm
    # Attachment data referenced by external URIs.
    class AttachmentDataLinks
      # @return [Array<String>] external URIs
      attr_accessor :links, :jws
      attr_writer :data_hash

      # @param links [Array<String>] external URIs to the attachment data
      # @param data_hash [String] hash of the data for integrity verification
      # @param jws [String, nil] optional JWS signature
      def initialize(links:, data_hash:, jws: nil)
        @links = links
        @data_hash = data_hash
        @jws = jws
      end

      # @return [String] hash of the data for integrity verification
      def data_hash
        @data_hash
      end

      # @return [Hash] serialized representation
      def to_hash
        d = { "links" => @links, "hash" => @data_hash }
        d["jws"] = @jws if @jws
        d
      end

      # @param d [Hash] serialized attachment data
      # @return [AttachmentDataLinks]
      def self.from_hash(d)
        new(links: d["links"], data_hash: d["hash"], jws: d["jws"])
      end
    end

    # Attachment data encoded inline as Base64.
    class AttachmentDataBase64
      # @return [String] Base64-encoded data
      attr_accessor :base64, :jws
      attr_writer :data_hash

      # @param base64 [String] Base64-encoded data
      # @param data_hash [String, nil] optional hash for integrity verification
      # @param jws [String, nil] optional JWS signature
      def initialize(base64:, data_hash: nil, jws: nil)
        @base64 = base64
        @data_hash = data_hash
        @jws = jws
      end

      # @return [String, nil] optional hash for integrity verification
      def data_hash
        @data_hash
      end

      # @return [Hash] serialized representation
      def to_hash
        d = { "base64" => @base64 }
        d["hash"] = @data_hash if @data_hash
        d["jws"] = @jws if @jws
        d
      end

      # @param d [Hash] serialized attachment data
      # @return [AttachmentDataBase64]
      def self.from_hash(d)
        new(base64: d["base64"], data_hash: d["hash"], jws: d["jws"])
      end
    end

    # Attachment data embedded as inline JSON.
    class AttachmentDataJson
      # @return [Hash, Array, String] inline JSON data
      attr_accessor :json, :jws
      attr_writer :data_hash

      # @param json [Hash, Array, String] inline JSON data
      # @param data_hash [String, nil] optional hash for integrity verification
      # @param jws [String, nil] optional JWS signature
      def initialize(json:, data_hash: nil, jws: nil)
        @json = json
        @data_hash = data_hash
        @jws = jws
      end

      # @return [String, nil] optional hash for integrity verification
      def data_hash
        @data_hash
      end

      # @return [Hash] serialized representation
      def to_hash
        d = { "json" => @json }
        d["hash"] = @data_hash if @data_hash
        d["jws"] = @jws if @jws
        d
      end

      # @param d [Hash] serialized attachment data
      # @return [AttachmentDataJson]
      def self.from_hash(d)
        new(json: d["json"], data_hash: d["hash"], jws: d["jws"])
      end
    end

    # A DIDComm message attachment with metadata and inline or linked data.
    class Attachment
      # @!attribute data
      #   @return [AttachmentDataLinks, AttachmentDataBase64, AttachmentDataJson] attachment payload
      # @!attribute id
      #   @return [String] unique attachment identifier (auto-generated UUID if omitted)
      # @!attribute description
      #   @return [String, nil] human-readable description
      # @!attribute filename
      #   @return [String, nil] suggested filename
      # @!attribute media_type
      #   @return [String, nil] MIME type of the attachment
      # @!attribute format
      #   @return [String, nil] attachment format identifier
      # @!attribute lastmod_time
      #   @return [Integer, nil] Unix timestamp of last modification
      # @!attribute byte_count
      #   @return [Integer, nil] size in bytes
      attr_accessor :data, :id, :description, :filename, :media_type, :format,
                    :lastmod_time, :byte_count

      # @param data [AttachmentDataLinks, AttachmentDataBase64, AttachmentDataJson] attachment payload
      # @param id [String, nil] unique identifier (auto-generated UUID if omitted)
      # @param description [String, nil] human-readable description
      # @param filename [String, nil] suggested filename
      # @param media_type [String, nil] MIME type
      # @param format [String, nil] format identifier
      # @param lastmod_time [Integer, nil] Unix timestamp of last modification
      # @param byte_count [Integer, nil] size in bytes
      def initialize(data:, id: nil, description: nil, filename: nil, media_type: nil,
                     format: nil, lastmod_time: nil, byte_count: nil)
        @data = data
        @id = id || SecureRandom.uuid
        @description = description
        @filename = filename
        @media_type = media_type
        @format = format
        @lastmod_time = lastmod_time
        @byte_count = byte_count
      end

      # @return [Hash] serialized representation
      def to_hash
        d = { "data" => @data.to_hash, "id" => @id }
        d["description"] = @description if @description
        d["filename"] = @filename if @filename
        d["media_type"] = @media_type if @media_type
        d["format"] = @format if @format
        d["lastmod_time"] = @lastmod_time if @lastmod_time
        d["byte_count"] = @byte_count if @byte_count
        d
      end

      # Deserialize an Attachment from a Hash.
      #
      # @param d [Hash] serialized attachment (with "data", "id", etc.)
      # @return [Attachment]
      # @raise [MalformedMessageError] if the data format is unrecognized
      def self.from_hash(d)
        raise MalformedMessageError.new(:invalid_plaintext) unless d.is_a?(Hash)

        data_hash = d["data"]
        raise MalformedMessageError.new(:invalid_plaintext) unless data_hash.is_a?(Hash)

        data = if data_hash.key?("links")
                 AttachmentDataLinks.from_hash(data_hash)
               elsif data_hash.key?("base64")
                 AttachmentDataBase64.from_hash(data_hash)
               elsif data_hash.key?("json")
                 AttachmentDataJson.from_hash(data_hash)
               else
                 raise MalformedMessageError.new(:invalid_plaintext)
               end

        new(
          data: data,
          id: d["id"],
          description: d["description"],
          filename: d["filename"],
          media_type: d["media_type"],
          format: d["format"],
          lastmod_time: d["lastmod_time"],
          byte_count: d["byte_count"]
        )
      end
    end
  end
end
