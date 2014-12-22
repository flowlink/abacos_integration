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
    add_value "products", products

    if (count = products.count) > 0
      result 200, "Received #{count} #{"product".pluralize count} from Ábacos"
    else
      result 200
    end
  end

  post "/get_orders" do
    orders = AbacosIntegration::Order.new(@config).fetch
    orders.each { |o| add_object "order", o }

    if (count = orders.count) > 0
      result 200, "Received #{count} #{"order".pluralize count} from Ábacos"
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

  post "/add_order" do
    order = AbacosIntegration::Order.new(@config, @payload)
    if order.create
      result 200, "Order #{@payload[:order][:id]} succesfully placed in Abacos"
    else
      result 500
    end
  end

  post "/get_shipments" do
    shipments = AbacosIntegration::Shipment.new(@config).fetch

    if (count = shipments.count) > 0
      add_value 'shipments', shipments
      result 200, "Received #{count} #{"shipment".pluralize count} (notas fiscais) from Ábacos"
    else
      result 200
    end
  end

  post "/confirm_shipment" do
    AbacosIntegration::Shipment.new(@config, @payload).confirm!
    result 200, "Shipment #{@payload[:shipment][:id]} integration confirmed"
  end

  post "/confirm_stock" do
    AbacosIntegration::Stock.new(@config, @payload).confirm!
    result 200, "Inventory #{@payload[:inventory][:id]} integration confirmed"
  end

  post "/confirm_product" do
    AbacosIntegration::Product.new(@config, @payload).confirm!
    result 200, "Product #{@payload[:product][:id]} integration confirmed"
  end

  post "/confirm_order_status" do
    AbacosIntegration::Order.new(@config, @payload).confirm!
    result 200, "Order #{@payload[:order][:id]} status update integration confirmed"
  end
end
