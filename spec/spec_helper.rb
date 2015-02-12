require 'rubygems'
require 'bundler'
require 'dotenv'

Dotenv.load
Bundler.require(:default, :test)

require File.join(File.dirname(__FILE__), '..', 'lib/abacos_integration')
require File.join(File.dirname(__FILE__), '..', 'abacos_endpoint')

Dir["./spec/support/**/*.rb"].each { |f| require f }

require 'spree/testing_support/controllers'

Sinatra::Base.environment = 'test'

ENV['ABACOS_KEY'] ||= 'key'
ENV['ABACOS_PRODUCTS_WSDL'] ||= 'http://abacos'
ENV['ABACOS_BASE_URL'] ||= 'http://abacos.com:8045/WSPlataforma'

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = false
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock

  # c.force_utf8_encoding = true

  c.filter_sensitive_data("ABACOS_KEY") { ENV["ABACOS_KEY"] }
  c.filter_sensitive_data("ABACOS_PRODUCTS_WSDL") { ENV["ABACOS_PRODUCTS_WSDL"] }
  c.filter_sensitive_data("ABACOS_BASE_URL") { ENV["ABACOS_BASE_URL"] }
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Spree::TestingSupport::Controllers

  config.filter_run_excluding :broken => true
end
