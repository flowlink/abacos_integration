require 'spec_helper'

describe Abacos do
  subject { described_class }

  context "product services" do
    before do
      subject.key ENV['ABACOS_KEY']
      subject.wsdl ENV['ABACOS_PRODUCTS_WSDL']
    end

    it "fetches products available" do
      VCR.use_cassette "products_available" do
        products = subject.products_available 
        expect(products).to be_a Array
      end
    end

    it "confirms products was received" do
      VCR.use_cassette "confirm_product_received" do
        result = subject.confirm_product_received "1BAB4A04-1987-4C3C-A7F0-D310985942D7"
        expect(result).to eq true
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
  end
end
