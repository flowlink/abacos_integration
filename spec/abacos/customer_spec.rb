require 'spec_helper'

class Abacos
  describe Customer do
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

    let(:attributes) do
      {
        "id" => "a123499452",
        "firstname" => "Brian",
        "lastname" => "Smith",
        "email" => "spree@example.com",
        "cpf_or_cnpj" => "000.000.000-00",
        "gender" => "feminino",
        "kind" => "fisica",
        "shipping_address" => address,
        "billing_address" => address
      }
    end

    it "assigns values" do
      subject = described_class.new

      subject.firstname = attributes['firstname']
      subject.email = attributes['email']

      subject.billing_address = attributes['billing_address']
      expect(subject.billing_address.state).to eq address['state']
    end

    it "hold values" do
      subject = described_class.new attributes

      expect(subject.firstname).to eq attributes['firstname']
      expect(subject.email).to eq attributes['email']
      expect(subject.billing_address.state).to eq address['state']
    end

    it "translates properly" do
      subject = described_class.new attributes

      expect(subject.translated).to eq(
        {
          "Nome" => "#{attributes['firstname']} #{attributes['lastname']}",
          "EMail" => attributes['email'],
          "CPFouCNPJ" => attributes['cpf_or_cnpj'],
          "TipoPessoa" => attributes['kind'],
          "Sexo" => attributes['gender'],
          "Endereco" => subject.billing_address.translated
        }
      )
    end
  end
end
