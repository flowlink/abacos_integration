require 'spec_helper'

module AbacosIntegration
  describe Product do
    include_examples "config"

    subject { described_class.new config }

    it "still allows other products from" do
      payload = {
        product: {
          abacos: { protocolo_produto: "p" },
          variants: {
            sku1: {
              abacos: { protocolo_produto: "sku1" }
            },
            sku2: {
              abacos: { protocolo_produto: "sku2" }
            }
          }
        }
      }

      subject = described_class.new config, payload
      expect(Abacos).to receive(:confirm_product_received).with("p").once
      expect(Abacos).to receive(:confirm_product_received).with("sku1").once.and_raise Abacos::ResponseError
      expect(Abacos).to receive(:confirm_product_received).with("sku2").once

      product_update = subject.confirm!
      expect(subject.pending_protocols).to eq ["sku1"]
      expect(subject.confirmed_protocols).to eq ["p", "sku2"]

      expected_return = {
        abacos: { protocolo_produto: nil },
        variants: {
          sku2: {
            abacos: { protocolo_produto: nil }
          }
        }
      }

      expect(product_update).to eq expected_return
    end

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
