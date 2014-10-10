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

  it "confirms stock received" do
    request = {
      parameters: config,
      inventory: {
        abacos: { protocolo_estoque: "bdcec9fb-f0f5-4223-8fc6-f369cb19ab05" }
      }
    }

    VCR.use_cassette "confirm_stock_received" do
      post "/confirm_stock", request.to_json, auth
      expect(last_response.status).to eq 200
    end
  end

  it "confirms product received" do
    request = {
      parameters: config,
      product: {
        abacos: { protocolo_produto: "1BAB4A04-1987-4C3C-A7F0-D310985942D7" }
      }
    }

    VCR.use_cassette "confirm_product_received" do
      post "/confirm_product", request.to_json, auth
      expect(last_response.status).to eq 200
    end
  end
end
