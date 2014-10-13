class Abacos
  # Translated general address into Abacos Address
  #
  # Example Abacos Address object:
  #
  #   "Endereco" => {
  #     "Logradouro" => "Santa Monica",
  #     "Estado" => "PI",
  #     "Municipio" => "Teresina",
  #     "Cep" => "64049905"
  #   }
  #
  # Regular Address:
  #
  #   "billing_address": {
  #     "address1": "1234 Awesome Street",
  #     "address2": "",
  #     "zipcode": "90210",
  #     "city": "Hollywood",
  #     "state": "California",
  #     "country": "US",
  #     "phone": "0000000000"
  #   }
  #
  # Cep needs to be 8 chars long
  #
  class Address
    attr_reader :attributes, :translated

    @@mappings = {
      "address1" => "Logradouro",
      "state" => "Estado",
      "city" => "Municipio",
      "zipcode" => "Cep"
    }

    attr_reader *@@mappings.keys

    def initialize(attributes = {})
      @attributes = attributes
      @translated = {}

      @@mappings.each do |k, v|
        instance_variable_set("@#{k}", translated[v] = attributes[k])
      end
    end

    def address1=(value)
      @address1 = translated["Logradouro"] = value
    end

    def state=(value)
      @state = translated["Estado"] = value
    end

    def city=(value)
      @city = translated["Municipio"] = value
    end

    def zipcode=(value)
      @zipcode = translated["Cep"] = value
    end
  end
end
