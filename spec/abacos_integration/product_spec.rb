require 'spec_helper'

module AbacosIntegration
  describe Product do
    include_examples "config"

    subject { described_class.new config }

    it "variants have a parent id", broken: true do
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

    it "also confirm variants received back to abacos" do
      protocol = {
        abacos: { protocolo_produto: "F123" }
      }

      payload = {
        product: {
          variants: { sku1: protocol }
        }
      }

      subject = described_class.new config, payload
      expect(Abacos).to receive(:confirm_product_received).with("F123").once
      subject.confirm!
    end

    it "dont confirm variants if abacos.protocolo_produto is not available" do
      payload = {
        product: {
          variants: {}
        }
      }

      subject = described_class.new config, payload
      expect(Abacos).not_to receive(:confirm_product_received)
      subject.confirm!
    end
  end
end
