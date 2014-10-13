$:.unshift File.dirname(__FILE__)

require 'abacos'
require 'abacos/helper'
require 'abacos/address'
require 'abacos/customer'
require 'abacos/line'
require 'abacos/payment'
require 'abacos/order'

module AbacosIntegration
  class Base
    def initialize(config = {})
      Abacos.key = config[:abacos_key]
      Abacos.base_path = config[:abacos_base_path]
    end
  end
end

require 'abacos_integration/product'
require 'abacos_integration/stock'
require 'abacos_integration/order'
