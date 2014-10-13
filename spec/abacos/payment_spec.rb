require_relative '../../lib/abacos'
require_relative '../../lib/abacos/payment'

class Abacos
  describe Payment do
    let(:attributes) do
      {
        "number" => 63,
        "status" => "completed",
        "installment_plan_number" => 1,
        "amount" => 100,
        "payment_method_id" => "1"
      }
    end

    it "hold values" do
      subject = described_class.new attributes

      expect(subject.amount).to eq attributes['amount']
      expect(subject.payment_method_id).to eq attributes['payment_method_id']
    end

    it "assigns values" do
      subject = described_class.new
      subject.amount = 333
      subject.installment_plan_number = 1
      subject.payment_method_id ||= 25
      expect(subject.payment_method_id).to eq 25
    end

    it "translates properly" do
      subject = described_class.new attributes

      expect(subject.translated).to eq(
        {
          "DadosPedidosFormaPgto" => {
            "FormaPagamentoCodigo" => attributes['payment_method_id'],
            "CartaoQtdeParcelas" => attributes['installment_plan_number'],
            "Valor" => attributes['amount']
          }
        }
      )
    end

    # Server was unable to read request. ---> There is an error in XML document (1, 1346). ---> Input string was not in a correct format.
    it "doesnt set nil values for keys" do
      attributes.delete "payment_method_id"
      subject = described_class.new attributes
      expect(subject.translated["DadosPedidosFormaPgto"].keys).to_not include("FormaPagamentoCodigo")
    end
  end
end
