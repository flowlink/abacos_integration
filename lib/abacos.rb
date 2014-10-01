class Abacos
  class ResponseError < StandardError; end

  class << self
    def key(key)
      @@key = key
    end

    def wsdl(wsdl)
      @@wsdl = wsdl
    end

    # e.g. http://187.120.13.174:8045/abacoswebsvc/AbacosWSProdutos.asmx?op=ProdutosDisponiveis
    #
    # Return a list of products created / updated or deleted in Abacos
    def products_available
      response = available_service :produtos_disponiveis
      result = response.body[:produtos_disponiveis_response][:produtos_disponiveis_result]

      if rows = result[:rows]
        if rows[:dados_produtos].is_a?(Array)
          rows[:dados_produtos]
        else
          [rows[:dados_produtos]]
        end
      end
    end

    # We need to return a confirmation to Abacos that product was received and
    # the integration was properly updated otherwise next time the
    # products_available call the same products (the same data) will be
    # brought again
    #
    def confirm_product_received(protocol)
      confirm_service "produto", protocol
    end

    def stocks_available
      response = available_service :estoques_disponiveis
      result = response.body[:estoques_disponiveis_response][:estoques_disponiveis_result]

      if rows = result[:rows]
        if rows[:dados_estoque].is_a?(Array)
          rows[:dados_estoque]
        else
          [rows[:dados_estoque]]
        end
      end
    end

    # Follows same logic as confirm_product_received
    def confirm_stock_received(protocol)
      confirm_service "estoque", protocol
    end

    def client
      Savon.client(
        ssl_verify_mode: :none,
        wsdl: @@wsdl,
        log_level: :info,
        pretty_print_xml: true,
        log: true
      )
    end

    def available_service(endpoint)
      client.call(endpoint, message: { "ChaveIdentificacao" => @@key })
    end

    def confirm_service(endpoint_key, protocol)
      endpoint = "confirmar_recebimento_#{endpoint_key}"
      response = client.call(
        endpoint.to_sym, message: { "Protocolo#{endpoint_key.capitalize}" => protocol }
      )

      first_key = :"confirmar_recebimento_#{endpoint_key}_response"
      second_key = :"confirmar_recebimento_#{endpoint_key}_result"
      result = response.body[first_key][second_key]

      if result[:tipo] != "tdreSucesso"
        raise ResponseError, "Could not confirm record was received. Cod. #{result[:codigo]}, #{result[:descricao]}"
      end

      true
    end
  end
end
