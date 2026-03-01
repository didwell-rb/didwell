# frozen_string_literal: true

module DID
  VerificationMaterial = Struct.new(:format, :value, keyword_init: true)
end
