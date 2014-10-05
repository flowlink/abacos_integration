module AbacosIntegration
  class Order < Base
    attr_reader :order, :order_payload

    def initialize(config, payload)
      super config
      @order_payload = payload[:order]
      @order = Abacos::Order.new order_payload
    end

    def create
      order.total = order_payload[:totals][:order]

      # NOTE Need to figure a way to check if the customer
      # exists. In case customer doesn't exist in Abacos we'll have to create
      # it first before creating the order
      Abacos.add_orders [order.translated]
    end
  end
end
