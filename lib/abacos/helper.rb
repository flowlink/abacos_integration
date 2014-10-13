require 'base64'

class Abacos
  class Helper
    class << self
      # Convert to Abacos date time format
      #
      #   ddmmyyyy hh:mm:ss.mmm => "09102014 00:12:00.000"
      #
      # Time parse will raise with "ArgumentError: argument out of range" if
      # string like "09102014 00:12:00.000" is given
      def parse_timestamp(string)
        time = Time.parse string
        time.strftime "%d%m%Y %H:%M:%S.%L"
      end

      def encrypt(data)
        cipher = OpenSSL::Cipher.new('des3')
        cipher.encrypt
        cipher.key = Abacos.des3_key
        cipher.iv = Abacos.des3_iv
        Base64.strict_encode64 cipher.update(data) + cipher.final
      end

      def decrypt(data)
        decoded_data = Base64.strict_decode64 data

        decipher = OpenSSL::Cipher.new('des3')
        decipher.decrypt
        decipher.key = Abacos.des3_key
        decipher.iv = Abacos.des3_iv

        decipher.update(decoded_data) + decipher.final
      end
    end
  end
end
