module AbacosIntegration
  class Product < Base
    attr_reader :product_payload, :variants_payload, :pending_protocols,
      :confirmed_protocols

    def initialize(config = {}, payload = {})
      super config

      @product_payload = payload[:product] || {}
      @variants_payload = product_payload[:variants] || {}

      @pending_protocols = []
      @confirmed_protocols = []
    end

    # Confirm product (if product.abacos info exists) and its variants. A
    # product payload might not be completely present because Abacos might
    # return the variant but not its master product via Abacos.products_available
    def confirm!
      confirm_integration product_payload
      variants_payload.each { |key, v| confirm_integration v }
      clean_up_protocols
    end

    def clean_up_protocols
      payload_update = { variants: {} }

      master_protocol = product_payload[:abacos].to_h[:protocolo_produto]
      if master_protocol && confirmed_protocols.include?(master_protocol)
        payload_update[:abacos] = { protocolo_produto: nil }
      end

      variants_payload.each do |sku, variant|
        protocol = variant[:abacos].to_h[:protocolo_produto]

        if protocol && confirmed_protocols.include?(protocol)
          payload_update[:variants] = {
            sku => { abacos: { protocolo_produto: nil } }
          }
        end
      end

      payload_update
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
          abacos: clean_up_keys(p)
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
      if ["1", "true", 1].include? config[:abacos_fetch_price].to_s
        if price = prices.find { |p| p[:codigo_produto] == product_id }
          { price: price[:preco_tabela], promotional_price: price[:preco_promocional] }
        else
          { price: 0 }
        end
      else
        { price: 0 }
      end
    end

    def build_variants(product_id)
      variants = variants_by_product_id product_id

      variants.inject({}) do |items, v|
        sku = v[:codigo_produto]

        items[sku] = {
          sku: sku,
          description: v[:descricao],
          abacos: clean_up_keys(v)
        }.merge fetch_price(v[:codigo_produto])

        items
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
      def clean_up_keys(hash)
        hash.keys.each do |k|
          if k =~ /campo_cfg/
            hash.delete k
          end
        end

        hash
      end

      def strip(string)
        string.to_s.strip! || string
      end

      def confirm_integration(payload)
        if payload[:abacos].to_h[:protocolo_produto]
          protocol = payload[:abacos][:protocolo_produto]

          Abacos.confirm_product_received protocol
          confirmed_protocols.push protocol
        end
      rescue Abacos::ResponseError => e
        pending_protocols.push payload[:abacos][:protocolo_produto]
      end

      def useless_keys
        [
          :dados_livros, :descritor_simples, :descritor_pre_definido,
          :atributos_estendidos, :produtos_personalizacao, :categorias_do_site,
          :componentes_kit, :produtos_associados
        ]
      end
  end
end
