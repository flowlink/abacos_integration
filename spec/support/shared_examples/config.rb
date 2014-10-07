shared_examples "config" do
  let(:config) do
    {
      abacos_key: ENV['ABACOS_KEY'],
      abacos_base_path: ENV['ABACOS_BASE_URL']
    }
  end
end
