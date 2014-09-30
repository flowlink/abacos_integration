class Abacos
  class << self
    def key(key)
      @@key = key
    end

    def wsdl(wsdl)
      @@wsdl = wsdl
    end

    def service(endpoint)
      client = Savon.client(
        ssl_verify_mode: :none,
        wsdl: @@wsdl,
        log_level: :info,
        pretty_print_xml: true,
        log: true
      )

      client.call(endpoint, message: { "ChaveIdentificacao" => @@key })
    end

    # e.g. http://187.120.13.174:8045/abacoswebsvc/AbacosWSProdutos.asmx?op=ProdutosDisponiveis
    #
    # Return a list of products created / updated or deleted in Abacos
    #
    # NOTE Apparently we need to return some sort of confirmation to Abacos
    # that we received those products otherwise next time this call is done
    # again the same repeated products will be returned
    def products_available
      response = service :produtos_disponiveis
      result = response.body[:produtos_disponiveis_response][:produtos_disponiveis_result]

      if rows = result[:rows]
        if rows[:dados_produtos].is_a?(Array)
          rows[:dados_produtos]
        else
          [rows[:dados_produtos]]
        end
      end
    end

    def stocks_available
      response = service :estoques_disponiveis
      result = response.body[:estoques_disponiveis_response][:estoques_disponiveis_result]

      if rows = result[:rows]
        if rows[:dados_estoque].is_a?(Array)
          rows[:dados_estoque]
        else
          [rows[:dados_estoque]]
        end
      end
    end
  end
end
