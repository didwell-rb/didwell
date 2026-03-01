# frozen_string_literal: true

module DIDRain
  module DID
    # Constants for W3C DID verification method type identifiers.
    module VerificationMethodType
      JSON_WEB_KEY_2020 = "JsonWebKey2020"
      X25519_KEY_AGREEMENT_KEY_2019 = "X25519KeyAgreementKey2019"
      ED25519_VERIFICATION_KEY_2018 = "Ed25519VerificationKey2018"
      X25519_KEY_AGREEMENT_KEY_2020 = "X25519KeyAgreementKey2020"
      ED25519_VERIFICATION_KEY_2020 = "Ed25519VerificationKey2020"
      MULTIKEY = "Multikey"
      JSON_WEB_KEY = "JsonWebKey"
      OTHER = "Other"

      ALL = [
        JSON_WEB_KEY_2020,
        X25519_KEY_AGREEMENT_KEY_2019,
        ED25519_VERIFICATION_KEY_2018,
        X25519_KEY_AGREEMENT_KEY_2020,
        ED25519_VERIFICATION_KEY_2020,
        MULTIKEY,
        JSON_WEB_KEY,
        OTHER
      ].freeze
    end
  end
end
