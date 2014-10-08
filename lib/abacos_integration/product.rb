module AbacosIntegration
  class Product < Base
    def initialize(config = {})
      super config
    end

    def fetch
      Abacos.products_available.map do |p|
        { id: p[:codigo_produto], abacos: p }
      end
    end
  end
end
