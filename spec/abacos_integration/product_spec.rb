require 'spec_helper'

module AbacosIntegration
  describe Product do
    include_examples "config"

    subject { described_class.new config }

    it "variants have a parent id" do
      VCR.use_cassette "products_available_1413298752" do
        products = subject.fetch

        expect(products.first).to have_key :price
        expect(products.first[:taxons]).to be_a Array
      end

      expect(subject.variants.first[:codigo_produto_pai]).to be_present

      parents = subject.parent_products
      expect(parents.first[:codigo_produto_pai]).to eq nil
    end

    it "builds taxons out of groups" do
      taxons = subject.build_taxons descricao_grupo: " A", descricao_subgrupo: "D "
      expect(taxons).to eq [["A", "D"]]
    end
  end
end
