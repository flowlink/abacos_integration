module AbacosIntegration
  class Product < Base
    attr_reader :product_payload

    def initialize(config = {}, payload = {})
      super config
      @product_payload  = payload[:product] || {}
    end

    def fetch
      Abacos.products_available.map do |p|
        { id: p[:codigo_produto], abacos: p }
      end
    end

    def confirm!
      protocol = product_payload[:abacos][:protocolo_produto]
      Abacos.confirm_product_received protocol
    end
  end
end
