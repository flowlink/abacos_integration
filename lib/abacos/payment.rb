class Abacos
  # Abacos > InserirPedido > DadosPedidos > FormasDePagamento
  #
  #   {
  #     "DadosPedidosFormaPgto" => {
  #       "FormaPagamentoCodigo" => "25",
  #       "CartaoQtdeParcelas" => 1,
  #       "Valor" => 100
  #     }
  #   }
  #
  class Payment
    attr_reader :attributes

    @@mappings = {
      "payment_method_id" => "FormaPagamentoCodigo",
      "installment_plan_number" => "CartaoQtdeParcelas",
      "amount" => "Valor"
    }

    attr_reader *@@mappings.keys

    def initialize(attributes = {})
      @attributes = attributes
      @translated = {}

      @@mappings.each do |k, v|
        instance_variable_set("@#{k}", @translated[v] = attributes[k])
      end
    end

    def translated
      { "DadosPedidosFormaPgto" => @translated }
    end
  end
end
