# frozen_string_literal: true

module DIDRain
  module DIDComm
    # Raised when an invalid value is passed to a DIDComm operation
    # (e.g. an invalid DID format).
    class ValueError < Error; end
  end
end
