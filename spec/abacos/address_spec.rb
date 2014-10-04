require_relative '../../lib/abacos'
require_relative '../../lib/abacos/address'

class Abacos
  describe Address do
    let(:address) do
      {
        "address1" => "1234 Awesome Street",
        "address2" => "",
        "zipcode" => "90210",
        "city" => "Hollywood",
        "state" => "California",
        "country" => "US",
        "phone" => "0000000000"
      }
    end

    it "assigns values" do
      subject = described_class.new

      subject.address1 = address['address1']
      subject.city = address['city']
      subject.state = address['state']
      subject.zipcode = address['zipcode']
    end

    it "hold values" do
      subject = described_class.new address

      expect(subject.address1).to eq address['address1']
      expect(subject.city).to eq address['city']
      expect(subject.state).to eq address['state']
      expect(subject.zipcode).to eq address['zipcode']
    end

    it "translates properly" do
      subject = described_class.new address
      expect(subject.translated).to eq(
        "Logradouro" => address['address1'],
        "Estado" => address['state'],
        "Municipio" => address['city'],
        "Cep" => address['zipcode']
      )
    end
  end
end
