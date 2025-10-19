# frozen_string_literal: true

module Eaton
  module Power
    # Get overall power consumption for the PDU
    # Returns power in watts
    def overall_power
      data = get("/powerDistributions/1/inputs/1")
      data.dig("measures", "activePower")
    end

    # Get per-outlet power consumption
    # Returns an array of hashes with outlet info and power in watts
    def outlet_power
      # Get list of outlets
      outlets_list = get("/powerDistributions/1/outlets")
      member_count = outlets_list["members@count"] || 0

      return [] if member_count.zero?

      # Get data for each outlet
      outlets = []
      outlets_list["members"].each do |member|
        outlet_id = member["@id"].split("/").last
        outlet_data = get("/powerDistributions/1/outlets/#{outlet_id}")

        outlets << {
          id: outlet_data["id"],
          name: outlet_data.dig("identification", "friendlyName") || "Outlet #{outlet_id}",
          physical_name: outlet_data.dig("identification", "physicalName"),
          watts: outlet_data.dig("measures", "activePower"),
          current: outlet_data.dig("measures", "current"),
          voltage: nil, # Outlets don't report voltage individually
          power_factor: outlet_data.dig("measures", "powerFactor"),
          state: outlet_data.dig("status", "switchedOn") ? "on" : "off",
          switched_on: outlet_data.dig("status", "switchedOn")
        }
      end

      outlets
    end

    # Get detailed power information including voltage, current, and power factor
    def detailed_power_info
      input_data = get("/powerDistributions/1/inputs/1")

      {
        overall: {
          watts: input_data.dig("measures", "activePower"),
          apparent_power: input_data.dig("measures", "apparentPower"),
          reactive_power: input_data.dig("measures", "reactivePower"),
          frequency: input_data.dig("measures", "frequency"),
          power_factor: input_data.dig("measures", "powerFactor"),
          percent_load: input_data.dig("measures", "percentLoad"),
          cumulated_energy: input_data.dig("measures", "cumulatedEnergy"),
          partial_energy: input_data.dig("measures", "partialEnergy")
        },
        outlets: outlet_power
      }
    end

    # Get branch power information
    # Returns an array of branch power data
    def branch_power
      branches_list = get("/powerDistributions/1/branches")
      member_count = branches_list["members@count"] || 0

      return [] if member_count.zero?

      branches = []
      branches_list["members"].each do |member|
        branch_id = member["@id"].split("/").last
        branch_data = get("/powerDistributions/1/branches/#{branch_id}")

        branches << {
          id: branch_data["id"],
          name: branch_data.dig("identification", "friendlyName") || "Branch #{branch_id}",
          physical_name: branch_data.dig("identification", "physicalName"),
          watts: branch_data.dig("measures", "activePower"),
          current: branch_data.dig("measures", "current"),
          voltage: branch_data.dig("measures", "voltage"),
          power_factor: branch_data.dig("measures", "powerFactor")
        }
      end

      branches
    end

    # Get PDU information
    def pdu_info
      data = get("/powerDistributions/1")

      {
        id: data["id"],
        name: data.dig("identification", "friendlyName"),
        model: data.dig("identification", "model"),
        serial_number: data.dig("identification", "serialNumber"),
        part_number: data.dig("identification", "partNumber"),
        vendor: data.dig("identification", "vendor"),
        firmware_version: data.dig("identification", "firmwareVersion"),
        status: data.dig("status", "operating"),
        health: data.dig("status", "health"),
        nominal_power: data.dig("specifications", "activePower", "nominal"),
        nominal_current: data.dig("specifications", "current", "nominal"),
        nominal_voltage: data.dig("specifications", "voltage", "nominal")
      }
    end
  end
end
