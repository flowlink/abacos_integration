require 'spec_helper'

describe AbacosEndpoint do
  include_examples "config"
  let(:order) { Factory.order }

  it "sends order to abacos" do
    request = { parameters: config, order: order }

    VCR.use_cassette "orders/#{order[:id]}" do
      post "/add_order", request.to_json, auth
      expect(json_response[:summary]).to match "succesfully placed in Abacos"
      expect(last_response.status).to eq 200
    end
  end

  it "receive products" do
    request = { parameters: config }

    VCR.use_cassette "435324532345" do
      post "/get_products", request.to_json, auth
      expect(json_response[:summary]).to match "products from Ábacos"
      expect(json_response[:products].count).to be >= 1
      expect(last_response.status).to eq 200
    end
  end

  it "receive products base path only config" do
    request = {
      parameters: config.merge(abacos_base_path_only: 1)
    }

    VCR.use_cassette "base_path_only_true" do
      post "/get_products", request.to_json, auth
      expect(json_response[:summary]).to eq nil
      expect(last_response.status).to eq 200
    end
  end

  pending "confirms stock received" do
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

  pending "confirms product received" do
    request = {
      parameters: config,
      product: {
        abacos: {
          protocolo_produto: "B9A0CB3D-9B05-4251-9310-E265D66E3663"
        }
      }
    }

    VCR.use_cassette "confirm_product_received" do
      post "/confirm_product", request.to_json, auth
      expect(json_response[:summary]).to match "integration confirmed"
      expect(last_response.status).to eq 200
    end
  end

  it "confirms order update received" do
    request = {
      parameters: config,
      order: {
        abacos: { protocolo_status_pedido: "C85869D8-1B01-4ECB-A3E9-E782E562CD75" }
      }
    }

    VCR.use_cassette "orders/confirm_order_status_received" do
      post "/confirm_order_status", request.to_json, auth
      expect(last_response.status).to eq 200
    end
  end

  it "gets invoices (notas fiscais) info as shipments" do
    request = { parameters: config }

    VCR.use_cassette "invoices/1415329420" do
      post "/get_shipments", request.to_json, auth
      expect(json_response[:summary]).to match /from Ábacos/
      expect(last_response.status).to eq 200
      expect(json_response[:shipments].count).to be >= 1
    end
  end

  it "confirms shipment received" do
    request = {
      parameters: config,
      shipment: {
        abacos: { :protocolo_nota_fiscal=>"1a94f1d2-7ef2-420f-bd51-67a409414da1" }
      }
    }

    VCR.use_cassette "invoices/4354353425" do
      post "/confirm_shipment", request.to_json, auth
      expect(json_response[:summary]).to match /integration confirmed/
      expect(last_response.status).to eq 200
    end
  end
end
