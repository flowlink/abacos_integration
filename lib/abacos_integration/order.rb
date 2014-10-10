module AbacosIntegration
  class Order < Base
    attr_reader :order, :order_payload

    def initialize(config, payload = {})
      super config
      @order_payload = payload[:order] || {}
      @order = Abacos::Order.new order_payload
    end

    def create
      order.total = order_payload[:totals][:order]

      send_customer_info
      Abacos.add_orders [order.translated]
    end

    def send_customer_info
      customer = Abacos::Customer.new customer_payload
      Abacos.add_customers [customer.translated]
    end

    def customer_payload
      {
        'firstname' => order_payload[:billing_address][:firstname],
        'lastname' => order_payload[:billing_address][:lastname],
        'email' => order_payload[:email],
        'cpf_or_cnpj' => order_payload[:cpf_or_cnpj],
        # NOTE Move defaults here to Abacos::Customer
        'kind' => order_payload[:kind] || "tpeFisica",
        'gender' => order_payload[:gender],
        'billing_address' => order_payload[:billing_address]
      }
    end

    # NOTE Map Order statuses (codigo_status). e.g.
    #
    #   ENT => delivered ?
    #
    def fetch
      Abacos.orders_available_status.map do |order|
        {
          id: order[:numero_pedido],
          abacos: order
        }
      end
    end
  end
end
