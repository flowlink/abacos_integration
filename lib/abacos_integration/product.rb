module AbacosIntegration
  class Product < Base
    attr_reader :product_payload

    def initialize(config = {}, payload = {})
      super config
      @product_payload  = payload[:product] || {}
    end

    # NOTE We need to loop through the product.variants and confirm
    # them as well?
    def confirm!
      protocol = product_payload[:abacos][:protocolo_produto]
      Abacos.confirm_product_received protocol
    end

    # Abacos return product children (variants) as regular product records
    # so here we need to make sure only parents products are returned with
    # their variants nested in the object
    def fetch
      handled_collection = build_from_parent_products
      parent_ids = handled_collection.map { |p| p[:id] }

      handled_collection + build_from_missing_parents(parent_ids)
    end

    def build_from_parent_products
      parent_products.map do |p|
        {
          id: p[:codigo_produto],
          name: p[:nome_produto],
          sku: p[:codigo_produto],
          description: p[:descricao],
          class: strip(p[:descricao_classe]),
          brand: strip(p[:descricao_marca]),
          family: strip(p[:descricao_familia]),
          taxons: build_taxons(p),
          variants: build_variants(p[:codigo_produto]),
          weight: p[:peso],
          height: p[:altura],
          width: p[:largura],
          length: p[:comprimento],
          abacos: p
        }.merge fetch_price(p[:codigo_produto])
      end
    end

    def build_from_missing_parents(parent_ids)
      variants_parent_ids = variants.map { |v| v[:codigo_produto_pai] }.uniq

      variants_parent_ids.inject([]) do |objects, parent|
        unless parent_ids.include? parent
          objects.push(
            id: parent,
            variants: build_variants(parent)
          )
        end

        objects
      end
    end

    def parent_products
      @parent_products ||= collection.reject { |p| p[:codigo_produto_pai] }
    end

    def variants
      @variants ||= collection.select { |p| p[:codigo_produto_pai] }
    end

    def fetch_price(product_id)
      if price = prices.find { |p| p[:codigo_produto] == product_id }
        { price: price[:preco_tabela], promotional_price: price[:preco_promocional] }
      else
        { price: 0 }
      end
    end

    def build_variants(product_id)
      variants = variants_by_product_id product_id

      variants.map do |v|
        {
          sku: v[:codigo_produto],
          description: v[:descricao],
          abacos: v
        }.merge fetch_price(v[:codigo_produto])
      end
    end

    def build_taxons(product)
      taxons = [
        strip(product[:descricao_grupo]), strip(product[:descricao_subgrupo])
      ].compact

      [taxons]
    end

    def variants_by_product_id(product_id)
      variants.select { |v| v[:codigo_produto_pai] == product_id }
    end

    def prices
      @prices ||= Abacos.price_online abacos_ids
    end

    def collection
      @collection ||= Abacos.products_available
    end

    def abacos_ids
      @abacos_ids ||= collection.map { |p| p[:codigo_produto] }
    end

    private
      def strip(string)
        string.to_s.strip! || string
      end
  end
end
