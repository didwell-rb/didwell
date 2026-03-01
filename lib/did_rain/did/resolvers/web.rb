# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module DIDRain
  module DID
    module Resolvers
      # Resolver for `did:web` method identifiers. Fetches DID documents over HTTPS.
      #
      # @example Resolve a did:web
      #   resolver = DIDRain::DID::Resolvers::Web.new
      #   doc = resolver.resolve("did:web:example.com")
      #
      # @example With a custom fetcher (useful for testing)
      #   fetcher = ->(url) { File.read("did.json") }
      #   resolver = DIDRain::DID::Resolvers::Web.new(fetcher: fetcher)
      class Web
        include DID::Resolver

        # @api private
        IPV4_PATTERN = /\A\d{1,3}(\.\d{1,3}){3}\z/
        # @api private
        MAX_REDIRECTS = 3
        # @api private
        ALLOWED_CONTENT_TYPES = %w[application/json application/did+ld+json application/ld+json].freeze

        # @param fetcher [#call, nil] callable that takes a URL string and returns the response body.
        #   Defaults to an internal HTTPS fetcher.
        # @param open_timeout [Integer] connection open timeout in seconds (default 5)
        # @param read_timeout [Integer] read timeout in seconds (default 5)
        def initialize(fetcher: nil, open_timeout: 5, read_timeout: 5)
          @fetcher = fetcher || default_fetch(open_timeout, read_timeout)
        end

        # Convert a `did:web` identifier to the HTTPS URL of its DID document.
        #
        # @param did [String] a `did:web:` identifier
        # @return [String] the HTTPS URL
        # @raise [InvalidDocumentError] if the DID is malformed or uses an IP address
        def self.did_to_url(did)
          parts = did.split(":")
          raise InvalidDocumentError, "Malformed did:web identifier" if parts.length < 3
          raise InvalidDocumentError, "Not a did:web identifier" unless parts[0] == "did" && parts[1] == "web"

          domain = percent_decode(parts[2])
          raise InvalidDocumentError, "Malformed did:web identifier" if domain.empty?
          raise InvalidDocumentError, "did:web MUST NOT contain userinfo" if domain.include?("@")

          host = domain.split(":").first
          raise InvalidDocumentError, "did:web MUST NOT use IP addresses" if ip_address?(host)

          if parts.length == 3
            "https://#{domain}/.well-known/did.json"
          else
            path = parts[3..].join("/")
            "https://#{domain}/#{path}/did.json"
          end
        end

        # Resolve a `did:web` identifier to a DID Document.
        #
        # @param did [String] a `did:web:` identifier
        # @return [Document, nil] the resolved document, or nil if not a did:web
        # @raise [InvalidDocumentError] if the document id does not match the DID
        # @raise [DocumentNotResolvedError] if the document cannot be fetched
        def resolve(did)
          return nil unless did.start_with?("did:web:")

          url = self.class.did_to_url(did)
          body = @fetcher.call(url)
          doc = Document::Parser.parse_json(body)

          raise InvalidDocumentError, "Document id '#{doc.id}' does not match DID '#{did}'" if doc.id != did

          doc
        rescue DocumentNotResolvedError
          raise DocumentNotResolvedError, did
        end

        # RFC 3986 percent-decoding without `+` to space conversion.
        # @api private
        def self.percent_decode(str)
          str.gsub(/%[0-9A-Fa-f]{2}/) { |match| [match[1..2].to_i(16)].pack("C") }
        end

        # @api private
        def self.ip_address?(host)
          return true if host.match?(IPV4_PATTERN)
          return true if host.start_with?("[")
          false
        end

        private_class_method :percent_decode, :ip_address?

        private

        def default_fetch(open_timeout, read_timeout)
          lambda do |url_string|
            uri = URI.parse(url_string)
            fetch_with_redirects(uri, open_timeout, read_timeout, MAX_REDIRECTS)
          end
        end

        def fetch_with_redirects(uri, open_timeout, read_timeout, remaining_redirects)
          raise DocumentNotResolvedError, uri.to_s if remaining_redirects < 0

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.open_timeout = open_timeout
          http.read_timeout = read_timeout

          response = http.request(Net::HTTP::Get.new(uri))

          case response
          when Net::HTTPSuccess
            validate_content_type!(response, uri)
            response.body
          when Net::HTTPRedirection
            location = URI.join(uri, response["location"])
            raise DocumentNotResolvedError, uri.to_s unless location.scheme == "https"

            fetch_with_redirects(location, open_timeout, read_timeout, remaining_redirects - 1)
          else
            raise DocumentNotResolvedError, uri.to_s
          end
        end

        def validate_content_type!(response, uri)
          content_type = response["content-type"]&.split(";")&.first&.strip&.downcase
          return if content_type.nil?
          return if ALLOWED_CONTENT_TYPES.include?(content_type)

          raise DocumentNotResolvedError, uri.to_s
        end
      end
    end
  end
end
