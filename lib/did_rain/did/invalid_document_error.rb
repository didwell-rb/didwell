# frozen_string_literal: true

module DIDRain
  module DID
    # Raised when a DID Document is structurally invalid or fails validation.
    class InvalidDocumentError < Error; end
  end
end
