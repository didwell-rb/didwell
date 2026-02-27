# frozen_string_literal: true

module DIDComm
  module DIDUtils
    DID_PATTERN = /\Adid:[a-z0-9]+:.+\z/
    DID_URL_PATTERN = /\Adid:[a-z0-9]+:.+#.+\z/

    def self.is_did(str)
      DID_PATTERN.match?(str)
    end

    def self.is_did_url(str)
      DID_URL_PATTERN.match?(str)
    end

    def self.did_from_did_url(did_url)
      did_url.split("#").first
    end

    def self.did_or_url(did_or_url)
      if did_or_url.include?("#")
        [did_or_url.split("#").first, did_or_url]
      else
        [did_or_url, nil]
      end
    end
  end
end
