# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-20

### Added
- Initial release
- OAuth2 bearer token authentication with Eaton PDU G4 devices
- Power monitoring commands:
  - `eaton power` - Overall power consumption
  - `eaton outlets` - Per-outlet power monitoring
  - `eaton branches` - Branch power distribution
  - `eaton detailed` - Detailed power metrics
  - `eaton info` - PDU device information
  - `eaton auth` - Authentication testing
- Smart filtering: text mode shows only active outlets/branches, JSON shows all
- SSH tunneling support via custom host headers
- Dual output formats: human-friendly text and machine-readable JSON
- Ruby API for programmatic access
- Support for 42 outlets and 6 branches
- Metrics include: watts, voltage, current, power factor, frequency, load percentage

### Features
- Zero-dependency HTTP client (uses Ruby's Net::HTTP)
- Automatic token management and session cleanup
- Comprehensive error handling
- CLI built with Thor
- Compatible with Ruby 3.0+

[0.1.0]: https://github.com/usiegj00/eaton/releases/tag/v0.1.0
