require 'spec_helper'

describe AbacosEndpoint do
  include_examples "config"
  let(:order) { Factory.order }

  it "sends order to abacos" do
    request = { parameters: config, order: order }

    VCR.use_cassette "orders/#{order[:id]}" do
      post "/add_order", request.to_json, auth
      expect(last_response.status).to eq 200
    end
  end
end
