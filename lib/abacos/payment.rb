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
        if attributes[k]
          instance_variable_set("@#{k}", @translated[v] = attributes[k])
        end

        self.class.send(:define_method, "#{k}=") do |value|
          instance_variable_set("@#{k}",  @translated[v] = value)
        end
      end
    end

    def translated
      { "DadosPedidosFormaPgto" => @translated }
    end
  end
end
