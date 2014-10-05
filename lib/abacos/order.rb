class Abacos
  # Abacos > InserirPedido > DadosPedidos
  #
  #   {
  #     "NumeroDoPedido" => "R34545465465463",
  #     "EMail" => "3JJiiLSOIJYAzifBXQbhY7T8aMPSc0G3ZXbXVUJUJt/HATZDaaHLXpTuWeBKxjjT",
  #     "CPFouCNPJ" => "GRoxtlUMehBt7Y39nFhGXw==",
  #     "ValorPedido" => "100",
  #     "DataVenda" => "02102014 00:12:00.000",
  #     "RepresentanteVendas" => 1,
  #     "Transportadora" => "Transp [Direct]",
  #     "ServicoEntrega" => "Transp [Direct]",
  #     "Itens" => [
  #       {
  #         "DadosPedidosItem" => {
  #           "CodigoProduto" => "3104376",
  #           "QuantidadeProduto" => 1,
  #           "PrecoUnitario" => 100
  #         }
  #       }
  #     ],
  #     "FormasDePagamento" => [
  #       {
  #         "DadosPedidosFormaPgto" => {
  #           "FormaPagamentoCodigo" => "25",
  #           "CartaoQtdeParcelas" => 1,
  #           "Valor" => 100
  #         }
  #       }
  #     ]
  #   }
  # 
  class Order
    attr_reader :attributes

    @@mappings = {
      "id" => "NumeroDoPedido",
      "email" => "EMail",
      "cpf_or_cnpj" => "CPFouCNPJ",
      "total" => "ValorPedido",
      "placed_on" => "DataVenda",
      "seller_id" => "RepresentanteVendas",
      "ship_carrier" => "Transportadora",
      "ship_service" => "ServicoEntrega",
    }

    @@obj_mappings = {
      "line_items" => "Abacos::Line Itens",
      "payments" => "Abacos::Payment FormasDePagamento"
    }

    attr_reader *@@mappings.keys
    attr_reader *@@obj_mappings.keys

    def initialize(attributes = {})
      @attributes = attributes
      @translated = {}

      @@mappings.each do |k, v|
        instance_variable_set("@#{k}", @translated[v] = attributes[k])

        self.class.send(:define_method, "#{k}=") do |value|
          instance_variable_set("@#{k}",  @translated[v] = value)
        end
      end

      @@obj_mappings.each do |k, v|
        klass, translation = v.split

        instance_variable_set("@#{k}", [])

        (attributes[k] || []).each do |line|
          instance = klass.constantize.new line
          @translated[translation] ||= []

          instance_variable_get("@#{k}").push instance
          @translated[translation].push instance.translated
        end
      end
    end

    def translated
      { "DadosPedidos" => @translated }
    end
  end
end
