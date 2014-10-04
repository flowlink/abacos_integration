class Abacos
  #
  #   {
  #     "DadosPedidosItem" => {
  #       "CodigoProduto" => "3104376",
  #       "QuantidadeProduto" => 1,
  #       "PrecoUnitario" => 100
  #     }
  #   }
  #
  class Line
    attr_reader :attributes

    @@mappings = {
      "product_id" => "CodigoProduto",
      "quantity" => "QuantidadeProduto",
      "price" => "PrecoUnitario"
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
      { "DadosPedidosItem" => @translated }
    end
  end
end
