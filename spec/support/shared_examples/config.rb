shared_examples "config" do
  let(:config) do
    {
      abacos_key: ENV['ABACOS_KEY'],
      abacos_wsdl: ENV['ABACOS_ORDERS_WSDL']
    }
  end
end
