require 'pry'
require 'active_support/inflector'

require_relative '../../lib/abacos'
require_relative '../../lib/abacos/address'
require_relative '../../lib/abacos/line'
require_relative '../../lib/abacos/payment'
require_relative '../../lib/abacos/order'

class Abacos
  describe Order do
    let(:attributes) do
      {
        "id" => "R154085346470432",
        "email" => "spree@example.com",
        "cpf_or_cnpj" => "000.000.000-00",
        "total" => "300.0",
        "seller_id" => "1",
        "ship_carrier" => "Mail",
        "ship_service" => "Mail",
        "placed_on" => "2014-02-03T17:29:15.219Z",
        "line_items" => [
          {
            "product_id" => "666",
            "name" => "Spree T-Shirt",
            "quantity" => 1,
            "price" => 100
          },
          {
            "product_id" => "7777",
            "name" => "Spree T-Shirt",
            "quantity" => 2,
            "price" => 100
          }
        ],
        "payments" => [
          {
            "number" => 63,
            "status" => "completed",
            "amount" => 123,
            "payment_method" => "Credit Card"
          },
          {
            "number" => 63,
            "status" => "completed",
            "amount" => 100,
            "payment_method" => "Credit Card"
          }
        ]
      }
    end

    it "hold values" do
      subject = described_class.new attributes

      expect(subject.id).to eq attributes["id"]
      expect(subject.email).to eq attributes["email"]
      expect(subject.total).to eq attributes["total"]

      expect(subject.line_items.count).to eq 2
      line = subject.line_items.first
      expect(line.product_id).to eq attributes['line_items'][0]['product_id']

      expect(subject.payments.count).to eq 2
      payment = subject.payments.first
      expect(payment.amount).to eq attributes['payments'][0]['amount']
    end

    it "assigns values" do
      subject = described_class.new

      subject.total = 10
      expect(subject.total).to eq 10

      subject.email = "wombat.co"
      expect(subject.email).to eq "wombat.co"
    end

    it "translates properly" do
      subject = described_class.new attributes
      translated = subject.translated["DadosPedidos"]

      expect(translated).to include(
        "NumeroDoPedido" => attributes['id'],
        "EMail" => attributes['email'],
        "CPFouCNPJ" => attributes['cpf_or_cnpj'],
        "ValorPedido" => attributes['total'],
        "DataVenda" => attributes['placed_on'],
        "RepresentanteVendas" => attributes['seller_id'],
        "Transportadora" => attributes['ship_carrier'],
        "ServicoEntrega" => attributes['ship_service']
      )

      line = Line.new attributes['line_items'][1]
      expect(translated['Itens'][1]).to eq line.translated

      payment = Payment.new attributes['payments'][1]
      expect(translated['FormasDePagamento'][1]).to eq payment.translated
    end

    # Server was unable to read request. ---> There is an error in XML document (1, 1346). ---> Input string was not in a correct format.
    it "doesnt set nil values for keys" do
      subject = described_class.new attributes
      expect(subject.translated["DadosPedidos"].keys).to_not include("ValorDesconto")
    end
  end
end
