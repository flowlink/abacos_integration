class Abacos
  # Required data for creating a customer record:
  #
  #   {
  #     "DadosClientes" => {
  #       "Nome" => "Wombat Integration First Client",
  #       "EMail" => "3JJiiLSOIJYAzifBXQbhY7T8aMPSc0G3ZXbXVUJUJt/HATZDaaHLXpTuWeBKxjjT",
  #       "CPFouCNPJ" => "GRoxtlUMehBt7Y39nFhGXw==",
  #       "TipoPessoa" => "tpeFisica",
  #       "Sexo" => "tseFeminino",
  #       "Endereco" => {
  #         "Logradouro" => "Santa Monica",
  #         "Estado" => "PI",
  #         "Municipio" => "Teresina",
  #         "Cep" => "64049905"
  #       }
  #     }
  #   }
  #
  class Customer
    @@mappings = {
      "email" => "EMail",
      "cpf_or_cnpj" => "CPFouCNPJ",
      "kind" => "TipoPessoa",
      "gender" => "Sexo"
    }

    @@obj_mappings = {
      "billing_address" => "Abacos::Address Endereco"
    }

    @@composed_mappings = {
      "firstname lastname" => "Nome"
    }

    attr_reader *@@mappings.keys
    attr_reader *@@obj_mappings.keys
    attr_reader *@@composed_mappings.keys.map(&:split).flatten

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

      @@obj_mappings.each do |k, v|
        klass, translation = v.split
        if attributes[k]
          instance = klass.constantize.new attributes[k]

          instance_variable_set("@#{k}", instance) 
          @translated[translation] = instance.translated
        end
      end

      @@composed_mappings.each do |k, v|
        @translated[v] = k.split.inject("") do |string, part|
          if attributes[part]
            instance_variable_set("@#{part}", attributes[part]) 
            string << " " + attributes[part] 
          end

          string.strip! || string
        end
      end
    end

    def firstname=(value)
      @firstname = value
    end

    def billing_address=(address)
      @billing_address = Address.new(address)
      @translated["Endereco"] = @billing_address.translated
      @billing_address
    end

    def translated
      { "DadosClientes" => @translated }
    end
  end
end
