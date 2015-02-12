require 'spec_helper'

describe Abacos, broken: true do
  subject { described_class }

  before do
    subject.key = ENV['ABACOS_KEY']
    subject.base_path = ENV['ABACOS_BASE_URL']
  end

  context "product services" do
    it "fetches products available" do
      VCR.use_cassette "products_available_1412880883" do
        products = subject.products_available 
        expect(products).to be_a Array
      end
    end

    it "still returns an array when no product is returned" do
      VCR.use_cassette "no_products_available" do
        products = subject.products_available
        expect(products).to be_a Array
      end
    end

    it "raise custom exception on abacos response error" do
      VCR.use_cassette "products/wrong_credentials" do
        subject.key = 'wrong key'
        expect {
          products = subject.products_available
        }.to raise_error Abacos::ResponseError
      end
    end

    it "confirms products was received" do
      VCR.use_cassette "confirm_product_received" do
        result = subject.confirm_product_received "1BAB4A04-1987-4C3C-A7F0-D310985942D7"
        expect(result).to eq true
      end
    end

    it "fetches product prices" do
      VCR.use_cassette "price_online" do
        prices = subject.price_online ["3104654"]
        expect(prices).to be_a Array
      end

      VCR.use_cassette "price_online_multiple" do
        prices = subject.price_online ["3104654", "3103099-2"]
        expect(prices).to be_a Array
      end
    end

    it "fetches prices available" do
      VCR.use_cassette "prices_available" do
        result = subject.prices_available
      end
    end

    it "fetches stocks available" do
      VCR.use_cassette "stocks_available" do
        stocks = subject.stocks_available 
        expect(stocks).to be_a Array
      end
    end

    it "confirms stock was received" do
      VCR.use_cassette "confirm_stock_received" do
        result = subject.confirm_stock_received "bdcec9fb-f0f5-4223-8fc6-f369cb19ab05"
        expect(result).to eq true
      end
    end

    it "fetches families available" do
      VCR.use_cassette "families_available" do
        families = subject.families_available 
        expect(families).to be_a Array
      end
    end

    it "fetches branding available" do
      VCR.use_cassette "branding_available" do
        brandings = subject.branding_available 
        expect(brandings).to be_a Array
      end
    end
  end

  context "order services" do
    it "adds order" do
      VCR.use_cassette "orders/add_order1412283955" do
        result = subject.add_orders [Factory.abacos_order]
      end
    end

    it "raises if can't create order" do
      VCR.use_cassette "orders/add_order1413223734" do
        expect {
          subject.add_orders [Factory.abacos_order]
        }.to raise_error Abacos::ResponseError
      end
    end

    it "receives order updates from abacos" do
      VCR.use_cassette "orders/orders_available" do
        o = subject.orders_available
      end
    end

    it "receives order status updates from abacos" do
      VCR.use_cassette "orders/orders_available_status1412903800" do
        result = subject.orders_available_status
        expect(result).to be_a Array
      end
    end

    it "confirm order status received" do
      VCR.use_cassette "orders/confirm_order_status_received" do
        result = subject.confirm_order_status_received "C85869D8-1B01-4ECB-A3E9-E782E562CD75"
        expect(result).to eq true
      end
    end
  end

  context "customer services" do
    it "adds customer" do
      VCR.use_cassette "add_customer_2014-10-02_17_25_31_-0300" do
        result = subject.add_customers [Factory.abacos_customer]
      end
    end

    it "raises if can save customer" do
      VCR.use_cassette "customers/add_customer1413224851" do
        expect {
          subject.add_customers [Factory.abacos_customer]
        }.to raise_error Abacos::ResponseError
      end
    end
  end

  context "invoices" do
    it "invoices available" do
      VCR.use_cassette "invoices/1415329420" do
        result = subject.invoices_available
        expect(result).to be_a Array
      end
    end
  end
end
