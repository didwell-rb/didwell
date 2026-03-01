# frozen_string_literal: true

module DIDRain
  module DID
    # Raised when a DID URL (verification method ID) cannot be found in a document.
    class UrlNotFoundError < Error; end
  end
end
