# frozen_string_literal: true

module Eaton
  # eth0 addressing on the PDU's network management card.
  module Network
    ETH0_PATH = "/managers/1/networkService/networkInterfaces/eth0"

    # Current eth0 addressing. :mode is "dhcp client" or "manual"; the address,
    # subnet_mask and gateway are what the interface is running on right now,
    # which is what DHCP handed it when the mode is dhcp.
    def ipv4
      data = get(ETH0_PATH)

      {
        mode: data.dig("ipv4", "settings", "mode"),
        address: data.dig("ipv4", "status", "address"),
        subnet_mask: data.dig("ipv4", "status", "subnetMask"),
        gateway: data.dig("ipv4", "status", "gateway")
      }
    end

    # Switch eth0 to a static address. All three values are required: the PDU
    # applies them together, and a wrong mask strands it on the wrong subnet.
    def set_ipv4(address:, subnet_mask:, gateway:)
      raise ArgumentError, "address, subnet_mask and gateway are all required" if
        [address, subnet_mask, gateway].any? { |v| v.to_s.strip.empty? }

      put(ETH0_PATH, ipv4: {
        settings: {
          enabled: true,
          mode: "manual",
          manual: { address: address, subnetMask: subnet_mask, gateway: gateway }
        }
      })
    end
  end
end
