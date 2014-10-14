require 'spec_helper'

module AbacosIntegration
  describe Product do
    include_examples "config"

    it "variants have a parent id" do
      subject = described_class.new config

      VCR.use_cassette "products_available_1413298752" do
        products = subject.fetch
        expect(products.first).to have_key :price
      end

      expect(subject.variants.first[:codigo_produto_pai]).to be_present

      parents = subject.parent_products
      expect(parents.first[:codigo_produto_pai]).to eq nil
    end
  end
end
