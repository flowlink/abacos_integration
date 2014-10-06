class Abacos
  class ResponseError < StandardError; end

  class Helper
    class << self
      def encrypt(data)
        cipher = OpenSSL::Cipher.new('des3')
        cipher.encrypt
        cipher.key = Abacos.des3_key
        cipher.iv = Abacos.des3_iv
        Base64.strict_encode64 cipher.update(data) + cipher.final
      end

      def decrypt(data)
        decoded_data = Base64.strict_decode64 data

        decipher = OpenSSL::Cipher.new('des3')
        decipher.decrypt
        decipher.key = Abacos.des3_key
        decipher.iv = Abacos.des3_iv

        decipher.update(decoded_data) + decipher.final
      end
    end
  end

  # Product Service
  #
  #   e.g. http://187.120.13.174:8045/AbacosWSProdutos.asmx
  #
  # Order Service
  #
  #   e.g. http://187.120.13.174:8045/AbacosWSPedidos.asmx
  #
  # Customer Service
  #
  #   e.g. http://187.120.13.174:8045/AbacosWSClientes.asmx
  #
  # NOTE we could ask the base path as a config and figure the service name
  # based on the webhook call
  class << self
    def key=(key)
      @@key = key
    end

    def wsdl=(wsdl)
      @@wsdl = wsdl
    end

    def des3_key=(key)
      @@des3_key = key
    end

    def des3_key
      @@des3_key
    end

    def des3_iv=(iv)
      @@des3_iv = iv
    end

    def des3_iv
      @@des3_iv
    end

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

    # Receives a collection of orders and send them to Abacos.
    #
    # Notes:
    #
    #   - Some fields need to be encrypted: email, cpf_cnpj and cc info
    #   - Customer referenced in the Order needs to exist in Abacos
    #   - Products referenced in the Order needs to exist in Abacos
    #   - Payment method id in the Order needs to exist in Abacos
    #
    def add_orders(orders = [])
      response = client.call(
        :inserir_pedido,
        message: {
          "ChaveIdentificacao" => @@key,
          "ListaDePedidos" => orders
        }
      )

      result = response.body[:inserir_pedido_response][:inserir_pedido_result]
      if result[:resultado_operacao][:tipo] != "tdreSucesso"
        raise ResponseError, "#{result[:rows]}"
      end

      response
    end

    def add_customers(customers = [])
      response = client.call(
        :cadastrar_cliente,
        message: {
          "ChaveIdentificacao" => @@key,
          "ListaDeClientes" => customers
        }
      )

      result = response.body[:cadastrar_cliente_response][:cadastrar_cliente_result]
      if result[:resultado_operacao][:tipo] != "tdreSucesso"
        raise ResponseError, "#{result[:rows]}"
      end

      response
    end

    # NOTE Intended to be private api below here

    def client
      Savon.client(
        # encoding: "ISO-8859-1",
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
