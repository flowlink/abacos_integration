require_relative '../../lib/abacos'
require_relative '../../lib/abacos/helper'

class Abacos
  describe Helper do
    subject { described_class }

    it "returns in abacos format" do
      time = Time.now.to_s
      subject.parse_timestamp time

      time = "2014-02-03T17:29:15.219Z"
      expect(subject.parse_timestamp time).to eq "03022014 17:29:15.219"
    end

    context "encryption" do
      subject { Abacos }

      before do
        Abacos.des3_key = ENV['ABACOS_DES3_KEY']
        Abacos.des3_iv = ENV['ABACOS_DES3_IV']
      end

      pending "encrypts and decrypts a string" do
        email = "washington@wombat.co"
        encrypted = Abacos::Helper.encrypt email

        expect(Abacos::Helper.decrypt encrypted).to eq email
      end
    end
  end
end
