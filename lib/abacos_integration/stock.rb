module AbacosIntegration
  class Stock < Base
    def initialize(config = {})
      super config
    end

    def fetch
      Abacos.stocks_available.map do |s|
        {
          id: s[:codigo_produto],
          product_id: s[:codigo_produto],
          quantity: s[:saldo_disponivel],
          abacos: s
        }
      end
    end
  end
end
