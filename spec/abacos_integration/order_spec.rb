require 'spec_helper'

module AbacosIntegration
  describe Order do
    include_examples "config"

    let(:order_payload) do
      Factory.order_payload
    end

    it "creates order in abacos" do
      # NOTE need to encrypt stuff here in case it doesnt come encrypted already
      order_payload[:email] = "3JJiiLSOIJYAzifBXQbhY7T8aMPSc0G3ZXbXVUJUJt/HATZDaaHLXpTuWeBKxjjT"
      order_payload[:cpf_or_cnpj] = "GRoxtlUMehBt7Y39nFhGXw=="

      # NOTE Need to parse and format the date accoding to Abacos
      order_payload[:placed_on] = "02102014 00:12:00.000"

      subject = described_class.new(config, order: order_payload)

      VCR.use_cassette "orders/#{order_payload[:id]}" do
        subject.create
      end
    end
  end
end
