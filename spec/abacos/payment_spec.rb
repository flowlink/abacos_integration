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
  end
end
