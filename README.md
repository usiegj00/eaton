# Eaton PDU Manager

A Ruby gem and CLI for managing Eaton Rack PDU G4 devices via REST API. Provides comprehensive power monitoring and management capabilities.

## Features

- 🔌 **Power Monitoring**: Overall, per-outlet, and per-branch power consumption
- 📊 **Detailed Metrics**: Voltage, current, power factor, frequency, load percentage
- 🔄 **Smart Filtering**: Text mode shows only active outlets/branches, JSON mode shows all
- 🔐 **OAuth2 Authentication**: Secure bearer token authentication
- 🌐 **SSH Tunneling**: Support for SSH tunneled connections via custom host headers
- 📝 **Dual Output**: Human-friendly text or machine-readable JSON

## Installation

Add to your Gemfile:

```ruby
gem 'eaton'
```

Or install directly:

```bash
gem install eaton
```

For development:

```bash
git clone https://github.com/usiegj00/eaton.git
cd eaton
bundle install
```

## Quick Start

```bash
# Get overall power consumption
eaton power \
  --host pdu.example.com \
  --username admin \
  --password your_password

# Get active outlets only (text mode)
eaton outlets \
  --host pdu.example.com \
  --username admin \
  --password your_password

# Get all outlets as JSON
eaton outlets \
  --host pdu.example.com \
  --username admin \
  --password your_password \
  --format json
```

## Commands

All commands support these options:
- `--host` - PDU hostname or IP (required)
- `--port` - PDU port (default: 443)
- `--username` - PDU username (required)
- `--password` - PDU password (required)
- `--host-header` - Custom Host header for SSH tunneling (optional)
- `--verify-ssl` - Verify SSL certificates (default: false)
- `--format` - Output format: `text` or `json` (default: text)

### Available Commands

| Command | Description |
|---------|-------------|
| `eaton auth` | Test authentication |
| `eaton info` | Display PDU device information |
| `eaton power` | Get overall power consumption (watts) |
| `eaton outlets` | Get per-outlet power consumption |
| `eaton branches` | Get per-branch power distribution |
| `eaton detailed` | Get detailed power metrics |

### Output Filtering

**Text Mode** (default):
- Shows only outlets/branches with active power draw
- Clean, focused output for human reading

**JSON Mode** (`--format json`):
- Shows all outlets/branches regardless of state
- Complete data for automation and monitoring systems

## Usage Examples

### Get PDU Information

```bash
eaton info --host pdu.example.com --username admin --password secret
```

Output:
```
PDU Device Information:
============================================================
id: 1
name: PDU
model: Eaton Rack PDU G4
serial_number: ABC123
vendor: Eaton
firmware_version: 2.9.2
status: in service
health: ok
nominal_power: 19800
nominal_current: 55
nominal_voltage: 208
```

### Monitor Overall Power

```bash
eaton power --host pdu.example.com --username admin --password secret
```

Output:
```
Overall Power:
============================================================
watts: 1542.3
```

### View Active Outlets

```bash
eaton outlets --host pdu.example.com --username admin --password secret
```

Shows only outlets currently drawing power.

### Export All Outlets to JSON

```bash
eaton outlets \
  --host pdu.example.com \
  --username admin \
  --password secret \
  --format json > outlets.json
```

### SSH Tunneling

When connecting through an SSH tunnel:

```bash
# SSH tunnel to remote PDU
ssh -L 5000:192.168.1.100:443 user@jumphost

# Connect via tunnel with custom host header
eaton power \
  --host localhost \
  --port 5000 \
  --username admin \
  --password secret \
  --host-header 192.168.1.100
```

## Ruby API

Use the gem programmatically in your Ruby code:

```ruby
require 'eaton'

# Create client
client = Eaton::Client.new(
  host: 'pdu.example.com',
  username: 'admin',
  password: 'secret',
  verify_ssl: true
)

# Get PDU info
info = client.info
puts "#{info[:model]} - #{info[:serial_number]}"

# Get overall power
power = client.power
puts "Current draw: #{power} watts"

# Get active outlets
outlets = client.outlets
outlets.select { |o| o[:watts] > 0 }.each do |outlet|
  puts "#{outlet[:name]}: #{outlet[:watts]}W"
end

# Get branch distribution
branches = client.branches
branches.each do |branch|
  puts "#{branch[:name]}: #{branch[:current]}A @ #{branch[:voltage]}V"
end

# Get detailed metrics
detailed = client.detailed
puts "Power Factor: #{detailed[:overall][:power_factor]}"
puts "Frequency: #{detailed[:overall][:frequency]} Hz"

# Clean up
client.logout
```

## API Endpoints

The gem interfaces with these REST API endpoints:

- `/powerDistributions/1` - PDU device information
- `/powerDistributions/1/inputs/1` - Overall power input
- `/powerDistributions/1/outlets/{id}` - Individual outlet data
- `/powerDistributions/1/branches/{id}` - Branch distribution data

## Supported Devices

Tested and verified with:
- **Eaton Rack PDU G4**
- Firmware: 2.9.2+
- API: `/rest/mbdetnrs/2.0`

Should work with other Eaton PDU models using the same API version.

## Authentication

Uses OAuth2 bearer token authentication:

1. POST credentials to `/oauth2/token/`
2. Receive access token
3. Include token in `Authorization: Bearer {token}` header
4. Token automatically managed and refreshed

## Development

```bash
# Clone repository
git clone https://github.com/usiegj00/eaton.git
cd eaton

# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Install locally
bundle exec rake install
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Create a Pull Request

## License

MIT License - see LICENSE file for details

## Support

- Issues: https://github.com/usiegj00/eaton/issues
- Documentation: https://github.com/usiegj00/eaton

## Credits

Developed for managing Eaton Rack PDU G4 devices via REST API.
