module AbacosIntegration
  class Product < Base
    attr_reader :product_payload

    def initialize(config = {}, payload = {})
      super config
      @product_payload  = payload[:product] || {}
    end

    # NOTE Dont return child products separately? they'd should be nested under
    # the master product key as variants
    #
    # NOTE What about Marcas and Familia? (Web services related to products)
    #
    # NOTE Do we need to fetch prices via another webservice?
    def fetch
      Abacos.products_available.map do |p|
        {
          id: p[:codigo_produto],
          name: p[:nome_produto],
          sky: p[:codigo_produto],
          description: p[:descricao],
          price: p[:preco_tabela1],
          abacos: p
        }
      end
    end

    def confirm!
      protocol = product_payload[:abacos][:protocolo_produto]
      Abacos.confirm_product_received protocol
    end
  end
end
