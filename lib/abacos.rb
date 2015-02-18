class Abacos
  class ResponseError < StandardError; end

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
  class << self
    def key=(key)
      @@key = key
    end

    def base_path=(base_path)
      @@base_path = base_path
    end

    @@webservice = "AbacosWSProdutos"
    @@base_path_only = false

    def base_path_only=(flag)
      @@base_path_only = flag
    end

    def base_path_only
      @@base_path_only
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
      @@webservice = "AbacosWSProdutos"
      result = available_service :produtos_disponiveis

      if rows = result[:rows]
        if rows[:dados_produtos].is_a?(Array)
          rows[:dados_produtos]
        else
          [rows[:dados_produtos]]
        end
      else
        []
      end
    end

    # We need to return a confirmation to Abacos that product was received and
    # the integration was properly updated otherwise next time the
    # products_available call the same products (the same data) will be
    # brought again
    #
    def confirm_product_received(protocol)
      @@webservice = "AbacosWSProdutos"
      confirm_service "produto", protocol
    end

    def price_online(product_ids = [])
      @@webservice = "AbacosWSProdutos"
      response = client.call(
        :preco_on_line,
        message: {
          "ChaveIdentificacao" => @@key,
          "ListaDeCodigosProdutos" => {
            "string" => product_ids
          }
        }
      )

      # NOTE We repeat this pattern too much, could be abstracted
      result = response.body[:preco_on_line_response][:preco_on_line_result]
      response_type = result[:resultado_operacao][:tipo]

      unless ["tdreSucesso", "tdreAlerta"].include? response_type
        error = result[:rows][:dados_preco_resultado][:resultado]
        message = "#{error[:codigo]}. #{error[:exception_message]}. \n#{error[:descricao]}"
        raise ResponseError, message
      end

      if rows = result[:rows]
        if rows[:dados_preco_resultado].is_a?(Array)
          rows[:dados_preco_resultado]
        else
          [rows[:dados_preco_resultado]]
        end
      else
        []
      end
    end

    def families_available
      @@webservice = "AbacosWSProdutos"
      result = available_service :familias_disponiveis

      if rows = result[:rows]
        if rows[:dados_familias_produtos].is_a?(Array)
          rows[:dados_familias_produtos]
        else
          [rows[:dados_familias_produtos]]
        end
      else
        []
      end
    end

    def branding_available
      @@webservice = "AbacosWSProdutos"
      result = available_service :marcas_disponiveis

      if rows = result[:rows]
        if rows[:dados_marcas_produtos].is_a?(Array)
          rows[:dados_marcas_produtos]
        else
          [rows[:dados_marcas_produtos]]
        end
      else
        []
      end
    end

    def prices_available
      @@webservice = "AbacosWSProdutos"
      result = available_service :precos_disponiveis
    end

    def stocks_available
      @@webservice = "AbacosWSProdutos"
      result = available_service :estoques_disponiveis

      if rows = result[:rows]
        if rows[:dados_estoque].is_a?(Array)
          rows[:dados_estoque]
        else
          [rows[:dados_estoque]]
        end
      else
        []
      end
    end

    # Follows same logic as confirm_product_received
    def confirm_stock_received(protocol)
      @@webservice = "AbacosWSProdutos"
      confirm_service "estoque", protocol
    end

    # Receives a collection of orders and send them to Abacos.
    #
    # Notes:
    #
    #   - Some fields need to be encrypted: email, cpf_cnpj and cc info (but
    #   the encryption can be disabled in Abacos)
    #   - Customer referenced in the Order needs to exist in Abacos
    #   - Products referenced in the Order needs to exist in Abacos
    #   - Payment method id in the Order needs to exist in Abacos
    #
    #   - Orders CANNOT be updated via API. Once they're sent users can only
    #   update it in Abacos itself.
    #
    def add_orders(orders = [])
      @@webservice = "AbacosWSPedidos"

      response = client.call(
        :inserir_pedido,
        message: {
          "ChaveIdentificacao" => @@key,
          "ListaDePedidos" => orders
        }
      )

      result = response.body[:inserir_pedido_response][:inserir_pedido_result]

      # NOTE think we will get a collection of :resultado_operacao when sending
      # more than one order. TEST IT and update the code to handle it as well
      if result[:resultado_operacao][:tipo] != "tdreSucesso"
        error = result[:rows][:dados_pedidos_resultado][:resultado]
        message = "#{error[:codigo]}. #{error[:exception_message]}. \n#{error[:descricao]}"
        raise ResponseError, message
      end

      response
    end

    # Return general Order updates
    # ps. don't know what we use this for ..
    def orders_available
      @@webservice = "AbacosWSPedidosDisponiveis"
      result = available_service :pedidos_disponiveis

      if rows = result[:rows]
        if rows[:dados_pedido_web].is_a?(Array)
          rows[:dados_pedido_web]
        else
          [rows[:dados_pedido_web]]
        end
      else
        []
      end
    end

    # Receives Order STATUS only updates from Abacos
    # This call is part of the Order integration process
    def orders_available_status
      @@webservice = "AbacosWSPedidos"
      result = available_service :status_pedido_disponiveis

      if rows = result[:rows]
        if rows[:dados_status_pedido].is_a?(Array)
          rows[:dados_status_pedido]
        else
          [rows[:dados_status_pedido]]
        end
      else
        []
      end
    end

    # Follows same logic as confirm_product_received
    def confirm_order_status_received(protocol)
      @@webservice = "AbacosWSPedidos"
      confirm_service "status_pedido", protocol
    end

    def invoices_available
      @@webservice = "AbacosWSNotasFiscais"
      result = available_service :notas_fiscais_disponiveis

      if rows = result[:rows]
        if rows[:dados_notas_fiscais_disponiveis_web].is_a?(Array)
          rows[:dados_notas_fiscais_disponiveis_web]
        else
          [rows[:dados_notas_fiscais_disponiveis_web]]
        end
      else
        []
      end
    end

    def confirm_invoice_received(protocol)
      @@webservice = "AbacosWSNotasFiscais"
      confirm_service "nota_fiscal", protocol
    end

    def add_customers(customers = [])
      @@webservice = "AbacosWSClientes"

      response = client.call(
        :cadastrar_cliente,
        message: {
          "ChaveIdentificacao" => @@key,
          "ListaDeClientes" => customers
        }
      )

      result = response.body[:cadastrar_cliente_response][:cadastrar_cliente_result]
      if result[:resultado_operacao][:tipo] != "tdreSucesso"
        if result[:rows]
          error = result[:rows][:dados_clientes_resultado][:resultado]
        else
          error = result[:resultado_operacao]
        end

        message = "#{error[:codigo]}. #{error[:exception_message]}. \n#{error[:descricao]}"
        raise ResponseError, message
      end

      response
    end

    def wsdl_url
      if base_path_only
        "#{@@base_path}.asmx?wsdl"
      else
        "#{@@base_path}/#{@@webservice}.asmx?wsdl"
      end
    end

    private

    # TODO Look into how httpi could be updated to support socket proxies.
    #
    #   e.g. proxy: 'socks5h://localhost:2222',
    #
    def client
      Savon.client(
        ssl_verify_mode: :none,
        wsdl: wsdl_url,
        log_level: :info,
        pretty_print_xml: true,
        read_timeout: 200,
        log: false
      )
    end

    def available_service(endpoint)
      response = client.call(endpoint, message: { "ChaveIdentificacao" => @@key })
      result = response.body[:"#{endpoint}_response"][:"#{endpoint}_result"]

      if error_message = result[:resultado_operacao][:exception_message]
        raise ResponseError, "#{result[:resultado_operacao][:codigo]}, #{error_message}"
      end

      result
    end

    def confirm_service(endpoint_key, protocol)
      endpoint = "confirmar_recebimento_#{endpoint_key}"
      response = client.call(
        endpoint.to_sym, message: { "Protocolo#{endpoint_key.camelize}" => protocol }
      )

      first_key = :"confirmar_recebimento_#{endpoint_key}_response"
      second_key = :"confirmar_recebimento_#{endpoint_key}_result"
      result = response.body[first_key][second_key]

      # NOTE Check if there's a exception_message key here
      if result[:tipo] != "tdreSucesso"
        raise ResponseError, "Could not confirm record was received with protocol '#{protocol}'. Cod. #{result[:codigo]}, #{result[:descricao]}, (Tipo: #{result[:tipo]})"
      end

      true
    end
  end
end
