module AbacosIntegration
  class Shipment < Base
    attr_reader :shipment_payload

    def initialize(config = {}, payload = {})
      super config
      @shipment_payload = payload[:shipment] || {}
    end

    def confirm!
      protocol = shipment_payload[:abacos][:protocolo_nota_fiscal]
      Abacos.confirm_invoice_received protocol
    end

    def fetch
      invoices = Abacos.invoices_available

      invoices.map do |invoice|
        {
          id: invoice[:codigo_nota_fiscal],
          abacos: invoice
        }
      end
    end
  end
end
