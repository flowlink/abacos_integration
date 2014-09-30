$:.unshift File.dirname(__FILE__)

require 'abacos'

module AbacosIntegration
  class Base
    def initialize(config = {})
      Abacos.key config[:abacos_key]
      Abacos.wsdl config[:abacos_wsdl]
    end
  end
end

require 'abacos_integration/product'
require 'abacos_integration/stock'
