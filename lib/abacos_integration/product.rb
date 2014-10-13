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

    # NOTE What about Marcas and Familia? (Web services related to products)
    #
    # NOTE Do we need to fetch prices via another webservice?
    #
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
          price: p[:preco_tabela1],
          variants: build_variants(p[:codigo_produto]),
          abacos: p
        }
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

    def build_variants(product_id)
      variants = variants_by_product_id product_id

      variants.map do |v|
        {
          sku: v[:codigo_produto],
          description: v[:descricao],
          price: v[:preco_tabela1],
          abacos: v
        }
      end
    end

    def variants_by_product_id(product_id)
      variants.select { |v| v[:codigo_produto_pai] == product_id }
    end

    def collection
      @collection ||= Abacos.products_available
    end
  end
end
