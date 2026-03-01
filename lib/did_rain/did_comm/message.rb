# frozen_string_literal: true

require "json"
require "securerandom"

module DIDRain
  module DIDComm
    # A DIDComm v2 plaintext message with standard and custom headers.
    #
    # @example Create a simple message
    #   msg = Message.new(type: "https://example.com/ping", body: { "response_requested" => true })
    class Message
      # @return [Array<String>] field names reserved by the DIDComm specification
      RESERVED_FIELDS = %w[
        ack attachments body created_time expires_time from from_prior
        id please_ack pthid thid to type
      ].freeze

      # @!attribute id
      #   @return [String] unique message identifier (auto-generated UUID if omitted)
      # @!attribute type
      #   @return [String] message type URI
      # @!attribute body
      #   @return [Hash] message body
      # @!attribute from
      #   @return [String, nil] sender DID
      # @!attribute to
      #   @return [Array<String>, nil] recipient DIDs
      # @!attribute created_time
      #   @return [Integer, nil] Unix timestamp of message creation
      # @!attribute expires_time
      #   @return [Integer, nil] Unix timestamp when the message expires
      # @!attribute from_prior
      #   @return [FromPrior, Hash, nil] from_prior header for DID rotation
      # @!attribute please_ack
      #   @return [Array<String>, nil] acknowledgement request
      # @!attribute ack
      #   @return [Array<String>, nil] acknowledgement of prior message IDs
      # @!attribute thid
      #   @return [String, nil] thread identifier
      # @!attribute pthid
      #   @return [String, nil] parent thread identifier
      # @!attribute attachments
      #   @return [Array<Attachment>, nil] message attachments
      # @!attribute custom_headers
      #   @return [Hash, nil] application-specific custom headers
      attr_accessor :id, :type, :body, :from, :to, :created_time, :expires_time,
                    :from_prior, :please_ack, :ack, :thid, :pthid, :attachments,
                    :custom_headers

      # @param type [String] message type URI
      # @param body [Hash] message body
      # @param id [String, nil] unique identifier (auto-generated UUID if omitted)
      # @param from [String, nil] sender DID
      # @param to [Array<String>, nil] recipient DIDs
      # @param created_time [Integer, nil] Unix timestamp of creation
      # @param expires_time [Integer, nil] Unix timestamp of expiry
      # @param from_prior [FromPrior, Hash, nil] DID rotation header
      # @param please_ack [Array<String>, nil] acknowledgement request
      # @param ack [Array<String>, nil] acknowledgement of prior messages
      # @param thid [String, nil] thread identifier
      # @param pthid [String, nil] parent thread identifier
      # @param attachments [Array<Attachment>, nil] message attachments
      # @param custom_headers [Hash, nil] application-specific headers
      def initialize(type:, body:, id: nil, from: nil, to: nil, created_time: nil,
                     expires_time: nil, from_prior: nil, please_ack: nil, ack: nil,
                     thid: nil, pthid: nil, attachments: nil, custom_headers: nil)
        @id = id || SecureRandom.uuid
        @type = type
        @body = body
        @from = from
        @to = to
        @created_time = created_time
        @expires_time = expires_time
        @from_prior = from_prior
        @please_ack = please_ack
        @ack = ack
        @thid = thid
        @pthid = pthid
        @attachments = attachments
        @custom_headers = custom_headers
      end

      # Serialize the message to a Hash.
      #
      # @return [Hash] the message as a plain Hash
      def to_hash
        d = {}
        d["id"] = @id
        d["type"] = @type
        d["body"] = @body
        d["typ"] = MessageTypes::PLAINTEXT
        d["from"] = @from if @from
        d["to"] = @to if @to
        d["created_time"] = @created_time if @created_time
        d["expires_time"] = @expires_time if @expires_time
        d["thid"] = @thid if @thid
        d["pthid"] = @pthid if @pthid
        d["please_ack"] = @please_ack if @please_ack
        d["ack"] = @ack if @ack

        if @from_prior
          d["from_prior"] = @from_prior.is_a?(FromPrior) ? @from_prior.to_hash : @from_prior
        end

        if @attachments
          d["attachments"] = @attachments.map { |a| a.is_a?(Attachment) ? a.to_hash : a }
        end

        if @custom_headers
          @custom_headers.each { |k, v| d[k] = v }
        end

        d
      end

      # Serialize the message to a JSON string.
      #
      # @return [String] JSON representation of the message
      def to_json(*_args)
        JSON.generate(to_hash)
      end

      # Deserialize a Message from a Hash.
      #
      # @param d [Hash] a hash with string keys matching DIDComm message fields
      # @return [Message] the deserialized message
      # @raise [MalformedMessageError] if required fields are missing or typ is invalid
      def self.from_hash(d)
        raise MalformedMessageError.new(:invalid_plaintext) unless d.is_a?(Hash)

        %w[id type body].each do |f|
          raise MalformedMessageError.new(:invalid_plaintext, "Missing required field: #{f}") unless d.key?(f)
        end

        d = d.dup

        typ = d.delete("typ")
        if typ && typ != MessageTypes::PLAINTEXT && typ != MessageTypes::PLAINTEXT_SHORT
          raise MalformedMessageError.new(:invalid_plaintext, "Invalid typ: #{typ}")
        end

        custom_headers = {}
        d.keys.each do |k|
          unless RESERVED_FIELDS.include?(k)
            custom_headers[k] = d.delete(k)
          end
        end

        from_prior = d["from_prior"]
        if from_prior.is_a?(Hash)
          from_prior = FromPrior.from_hash(from_prior)
        end

        attachments = d["attachments"]
        if attachments.is_a?(Array)
          attachments = attachments.map { |a| a.is_a?(Hash) ? Attachment.from_hash(a) : a }
        end

        new(
          id: d["id"],
          type: d["type"],
          body: d["body"],
          from: d["from"],
          to: d["to"],
          created_time: d["created_time"],
          expires_time: d["expires_time"],
          from_prior: from_prior,
          please_ack: d["please_ack"],
          ack: d["ack"],
          thid: d["thid"],
          pthid: d["pthid"],
          attachments: attachments,
          custom_headers: custom_headers.empty? ? nil : custom_headers
        )
      end

      # Deserialize a Message from a JSON string.
      #
      # @param json_str [String] JSON-encoded DIDComm message
      # @return [Message] the deserialized message
      # @raise [MalformedMessageError] if the message is invalid
      def self.from_json(json_str)
        from_hash(JSON.parse(json_str))
      end
    end
  end
end
