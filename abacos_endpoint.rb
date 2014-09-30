require "sinatra"
require "endpoint_base"

require File.expand_path(File.dirname(__FILE__) + '/lib/abacos_integration')

class AbacosEndpoint < EndpointBase::Sinatra::Base
  Honeybadger.configure do |config|
    config.api_key = ENV['HONEYBADGER_KEY']
    config.environment_name = ENV['RACK_ENV']
  end if ENV['HONEYBADGER_KEY'].present?

  post "/get_products" do
    products = AbacosIntegration::Product.new(@config).fetch
    products.each { |p| add_object "product", p }

    if (count = products.count) > 0
      result 200, "Received #{count} #{"product".pluralize count} from Ábacos"
    else
      result 200
    end
  end

  post "/get_inventory" do
    stocks = AbacosIntegration::Stock.new(@config).fetch
    stocks.each { |s| add_object "inventory", s }

    if (count = stocks.count) > 0
      result 200, "Received #{count} #{"inventory".pluralize count} from Ábacos"
    else
      result 200
    end
  end
end
