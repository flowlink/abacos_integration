require 'spec_helper'

module AbacosIntegration
  describe Product do
    include_examples "config"

    it "variants have a parent id" do
      subject = described_class.new config

      VCR.use_cassette "products_available_1412880883" do
        products = subject.fetch
      end

      expect(subject.variants.first[:codigo_produto_pai]).to be_present

      parents = subject.parent_products
      expect(parents.first[:codigo_produto_pai]).to eq nil
    end
  end
end
