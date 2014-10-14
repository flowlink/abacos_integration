module AbacosIntegration
  class Stock < Base
    attr_reader :inventory_payload

    def initialize(config = {}, payload = {})
      super config
      @inventory_payload = payload[:inventory] || {}
    end

    # We're using `codigo_produto_abacos` as the ID key here to facilicate
    # moving this info to a storefront that requires IDs to be unique numbers
    # only
    #
    # abacos_id can be used by integrations what requires a reference value
    # with only numbers (id might contain other chars)
    def fetch
      Abacos.stocks_available.map do |s|
        {
          id: s[:codigo_produto],
          # NOTE We might need to think about this, as this id will not a
          # product ID in wombat when the inventory refers to a variant
          product_id: s[:codigo_produto],
          abacos_id: s[:codigo_produto_abacos],
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
