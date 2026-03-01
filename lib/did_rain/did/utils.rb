# frozen_string_literal: true

module DIDRain
  module DID
    # Utility methods for DID and DID URL validation and parsing.
    module Utils
      # W3C DID grammar (https://www.w3.org/TR/did-1.1/#did-syntax):
      #   did                = "did:" method-name ":" method-specific-id
      #   method-specific-id = *( *idchar ":" ) 1*idchar
      #   idchar             = ALPHA / DIGIT / "." / "-" / "_" / pct-encoded
      #   pct-encoded        = "%" HEXDIG HEXDIG
      PCT_ENCODED = '%[0-9A-Fa-f]{2}'
      IDCHAR = "(?:[a-zA-Z0-9._-]|#{PCT_ENCODED})"
      METHOD_SPECIFIC_ID = "(?:#{IDCHAR}+:)*#{IDCHAR}+"
      DID_BASE = "did:[a-z0-9]+:#{METHOD_SPECIFIC_ID}"

      DID_PATTERN = /\A#{DID_BASE}(?:##{IDCHAR}+)?\z/
      DID_URL_PATTERN = /\A#{DID_BASE}##{IDCHAR}+\z/

      # Test whether a string is a valid DID (with optional fragment).
      #
      # @param str [String] the string to test
      # @return [Boolean]
      def self.is_did(str)
        DID_PATTERN.match?(str)
      end

      # Test whether a string is a DID URL (a DID with a fragment).
      #
      # @param str [String] the string to test
      # @return [Boolean]
      def self.is_did_url(str)
        DID_URL_PATTERN.match?(str)
      end

      # Extract the DID portion from a DID URL by stripping the fragment.
      #
      # @param did_url [String] a DID URL (e.g. "did:example:123#key-1")
      # @return [String] the DID without the fragment
      def self.did_from_did_url(did_url)
        did_url.split("#").first
      end

      # Split a DID or DID URL into its DID part and optional full DID URL.
      #
      # @param did_or_url [String] a DID or DID URL
      # @return [Array(String, String?)] a two-element array of [did, did_url_or_nil]
      def self.did_or_url(did_or_url)
        if did_or_url.include?("#")
          [did_or_url.split("#").first, did_or_url]
        else
          [did_or_url, nil]
        end
      end
    end
  end
end
