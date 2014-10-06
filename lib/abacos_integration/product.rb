module AbacosIntegration
  class Product < Base
    def initialize(config = {})
      super config
    end

    def fetch
      # NOTE we could make products_available always return an array?
      (Abacos.products_available || []).map do |p|
        { id: p[:codigo_produto], abacos: p }
      end
    end
  end
end
