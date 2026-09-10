# frozen_string_literal: true

RSpec.describe Eaton::Network do
  # A bare double of the surface Network leans on, so these stay unit tests.
  let(:client) do
    Class.new do
      include Eaton::Network

      attr_reader :put_calls

      def initialize(payload = {})
        @payload = payload
        @put_calls = []
      end

      def get(_path) = @payload

      def put(path, data = {})
        @put_calls << [path, data]
        ""
      end
    end
  end

  describe "#ipv4" do
    it "reads the address the interface is running on, not the manual block" do
      pdu = client.new(
        "ipv4" => {
          "status" => { "address" => "192.168.0.101", "subnetMask" => "255.255.252.0", "gateway" => "192.168.0.1" },
          "settings" => { "mode" => "dhcp client", "manual" => { "address" => "192.168.1.2" } }
        }
      )

      expect(pdu.ipv4).to eq(
        mode: "dhcp client",
        address: "192.168.0.101",
        subnet_mask: "255.255.252.0",
        gateway: "192.168.0.1"
      )
    end

    it "returns nils rather than raising when the interface reports nothing" do
      expect(client.new.ipv4.values).to all(be_nil)
    end
  end

  describe "#set_ipv4" do
    it "switches the interface to the given static address" do
      pdu = client.new
      pdu.set_ipv4(address: "192.168.0.100", subnet_mask: "255.255.252.0", gateway: "192.168.0.1")

      expect(pdu.put_calls.size).to eq(1)
      path, data = pdu.put_calls.first
      expect(path).to eq(described_class::ETH0_PATH)
      expect(data).to eq(
        ipv4: {
          settings: {
            enabled: true,
            mode: "manual",
            manual: { address: "192.168.0.100", subnetMask: "255.255.252.0", gateway: "192.168.0.1" }
          }
        }
      )
    end

    # A missing mask is the dangerous one: the PDU applies all three together,
    # and a wrong prefix can leave it unreachable.
    [
      { address: "", subnet_mask: "255.255.252.0", gateway: "192.168.0.1" },
      { address: "192.168.0.100", subnet_mask: "", gateway: "192.168.0.1" },
      { address: "192.168.0.100", subnet_mask: "255.255.252.0", gateway: nil },
      { address: "192.168.0.100", subnet_mask: "  ", gateway: "192.168.0.1" }
    ].each do |args|
      it "refuses to write when #{args.find { |_k, v| v.to_s.strip.empty? }.first} is missing" do
        pdu = client.new

        expect { pdu.set_ipv4(**args) }.to raise_error(ArgumentError, /all required/)
        expect(pdu.put_calls).to be_empty
      end
    end
  end
end
