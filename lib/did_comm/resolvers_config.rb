# frozen_string_literal: true

module DIDComm
  ResolversConfig = Struct.new(:did_resolver, :secrets_resolver, keyword_init: true)
end
