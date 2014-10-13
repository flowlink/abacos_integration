require 'spec_helper'

module AbacosIntegration
  describe Order do
    include_examples "config"
    let(:order_payload) { Factory.order }

    it "creates order in abacos" do
      subject = described_class.new(config, order: order_payload)

      VCR.use_cassette "orders/#{order_payload[:id]}" do
        subject.create
      end
    end

    it "fetches order updates from abacos" do
      subject = described_class.new(config)

      VCR.use_cassette "orders/orders_available_status1412903800" do
        orders = subject.fetch
        expect(orders).to be_a Array
      end
    end
  end
end
