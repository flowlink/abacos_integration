require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

require File.join(File.dirname(__FILE__), '..', 'lib/abacos_integration')
require File.join(File.dirname(__FILE__), '..', 'abacos_endpoint')

Dir["./spec/support/**/*.rb"].each { |f| require f }

require 'spree/testing_support/controllers'

Sinatra::Base.environment = 'test'

ENV['ABACOS_KEY'] ||= 'key'
ENV['ABACOS_PRODUCTS_WSDL'] ||= 'http://abacos'
ENV['ABACOS_ORDERS_WSDL'] ||= 'http://abacos'
ENV['ABACOS_CUSTOMERS_WSDL'] ||= 'http://abacos'
ENV['ABACOS_BASE_URL'] ||= 'http://abacos'

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = false
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock

  c.filter_sensitive_data("ABACOS_KEY") { ENV["ABACOS_KEY"] }
  c.filter_sensitive_data("ABACOS_PRODUCTS_WSDL") { ENV["ABACOS_PRODUCTS_WSDL"] }
  c.filter_sensitive_data("ABACOS_ORDERS_WSDL") { ENV["ABACOS_ORDERS_WSDL"] }
  c.filter_sensitive_data("ABACOS_CUSTOMERS_WSDL") { ENV["ABACOS_CUSTOMERS_WSDL"] }
  c.filter_sensitive_data("ABACOS_BASE_URL") { ENV["ABACOS_BASE_URL"] }

  # c.preserve_exact_body_bytes do |http_message|
  #   binding.pry
  #   http_message.body.encoding.name == 'ASCII-8BIT' ||
  #     !http_message.body.valid_encoding?
  # end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Spree::TestingSupport::Controllers
end
