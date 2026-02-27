# frozen_string_literal: true

require "openssl"

module DIDComm
  module Crypto
    module KeyWrap
      # AES Key Wrap (RFC 3394)
      # Uses AES-ECB as the block cipher
      def self.wrap(kek, plaintext_key)
        n = plaintext_key.bytesize / 8
        raise ArgumentError, "Key must be multiple of 8 bytes" unless plaintext_key.bytesize % 8 == 0

        # Default IV
        a = "\xA6\xA6\xA6\xA6\xA6\xA6\xA6\xA6".b
        r = Array.new(n) { |i| plaintext_key.byteslice(i * 8, 8) }

        cipher = OpenSSL::Cipher.new("aes-#{kek.bytesize * 8}-ecb")
        cipher.encrypt
        cipher.key = kek
        cipher.padding = 0

        6.times do |j|
          n.times do |i|
            b = cipher.update(a + r[i])
            t = (n * j + i + 1)
            t_bytes = [t].pack("Q>")
            a = xor_bytes(b[0, 8], t_bytes)
            r[i] = b[8, 8]
          end
        end

        a + r.join
      end

      def self.unwrap(kek, wrapped_key)
        n = (wrapped_key.bytesize / 8) - 1
        a = wrapped_key.byteslice(0, 8)
        r = Array.new(n) { |i| wrapped_key.byteslice((i + 1) * 8, 8) }

        cipher = OpenSSL::Cipher.new("aes-#{kek.bytesize * 8}-ecb")
        cipher.decrypt
        cipher.key = kek
        cipher.padding = 0

        5.downto(0) do |j|
          (n - 1).downto(0) do |i|
            t = (n * j + i + 1)
            t_bytes = [t].pack("Q>")
            a_xored = xor_bytes(a, t_bytes)
            b = cipher.update(a_xored + r[i])
            a = b[0, 8]
            r[i] = b[8, 8]
          end
        end

        expected_iv = "\xA6\xA6\xA6\xA6\xA6\xA6\xA6\xA6".b
        unless a == expected_iv
          raise MalformedMessageError.new(:can_not_decrypt, "Key unwrap integrity check failed")
        end

        r.join
      end

      def self.xor_bytes(a, b)
        a.bytes.zip(b.bytes).map { |x, y| (x ^ y).chr }.join.b
      end
    end
  end
end
