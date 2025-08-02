# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-08-03

### Added
- Initial release of HAOS Swap Enabler Add-on for Home Assistant
- Support for enabling swap on block devices and partitions
- Auto-discovery mode to find existing swap partitions
- Optional automatic partition creation on unpartitioned devices
- Configurable swap priority for multiple swap devices
- Comprehensive safety checks to prevent data loss
- Support for various device types (SATA, NVMe, USB, eMMC)
- Detailed logging and error reporting
- Device validation and existence checking
- Integration with Home Assistant supervisor

### Features
- Block device swap activation (e.g., `/dev/sdb`, `/dev/nvme0n1`)
- Automatic swap partition discovery
- Safe partition creation with user consent
- Priority-based swap management
- Comprehensive device compatibility
- Production-ready safety mechanisms
