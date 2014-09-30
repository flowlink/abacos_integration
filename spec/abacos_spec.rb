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

    it "fetches stocks available" do
      VCR.use_cassette "stocks_available" do
        stocks = subject.stocks_available 
        expect(stocks).to be_a Array
      end
    end
  end
end
