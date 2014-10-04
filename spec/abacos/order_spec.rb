require 'active_support/inflector'

require_relative '../../lib/abacos'
require_relative '../../lib/abacos/address'
require_relative '../../lib/abacos/line'
require_relative '../../lib/abacos/order'

class Abacos
  describe Order do
    let(:attributes) do
      {
        "id" => "R154085346470432",
        "email" => "spree@example.com",
        "placed_on" => "2014-02-03T17:29:15.219Z",
        "line_items" => [
          {
            "product_id" => "SPREE-T-SHIRT",
            "name" => "Spree T-Shirt",
            "quantity" => 2,
            "price" => 100
          }
        ],
        "payments" => [
          {
            "number" => 63,
            "status" => "completed",
            "amount" => 220,
            "payment_method" => "Credit Card"
          }
        ]
      }
    end

    it "hold values" do
      subject = described_class.new attributes
    end
  end
end
