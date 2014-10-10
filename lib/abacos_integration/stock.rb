module AbacosIntegration
  class Stock < Base
    attr_reader :inventory_payload

    def initialize(config = {}, payload = {})
      super config
      @inventory_payload = payload[:inventory] || {}
    end

    def fetch
      Abacos.stocks_available.map do |s|
        {
          id: s[:codigo_produto],
          product_id: s[:codigo_produto],
          quantity: s[:saldo_disponivel],
          location: s[:nome_almoxarifado_origem],
          abacos: s
        }
      end
    end

    def confirm!
      protocol = inventory_payload[:abacos][:protocolo_estoque]
      Abacos.confirm_stock_received protocol
    end
  end
end
