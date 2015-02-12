require 'spec_helper'

module AbacosIntegration
  describe Stock do
    include_examples "config"

    it "builds inventories collection", broken: true do
      subject = described_class.new config

      VCR.use_cassette "stocks_available" do
        inventories = subject.fetch

        expected_keys = [:id, :product_id, :quantity, :location, :abacos, :abacos_id]
        expect(inventories.first.keys).to match_array expected_keys
      end
    end
  end
end
