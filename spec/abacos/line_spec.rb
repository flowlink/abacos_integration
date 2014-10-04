require_relative '../../lib/abacos'
require_relative '../../lib/abacos/line'

class Abacos
  describe Line do
    let(:line) do
      {
        "product_id" => "123",
        "quantity" => 1,
        "price" => "10.0"
      }
    end

    it "hold values" do
      subject = described_class.new line

      expect(subject.product_id).to eq line['product_id']
      expect(subject.quantity).to eq line['quantity']
      expect(subject.price).to eq line['price']
    end
  end
end
