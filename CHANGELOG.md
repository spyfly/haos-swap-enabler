# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2025-08-03

### Fixed
- Removed conflicting device access configuration (full_access + devices)
- Fixed invalid capabilities (MKNOD, DAC_OVERRIDE) to use only allowed ones
- Simplified privilege configuration to use only SYS_ADMIN and SYS_RAWIO
- Resolved Home Assistant Supervisor validation warnings

### Changed
- Streamlined configuration to use full_access for complete system access
- Removed redundant device mappings when using full_access

## [1.0.2] - 2025-08-03

### Fixed
- Added full_access privilege for complete device access
- Enhanced error handling and debugging in partition creation
- Improved device accessibility checks before operations
- Added system information logging for troubleshooting
- Better error messages for permission issues

### Changed
- Enhanced privilege configuration for block device operations
- Added detailed device permission checks
- Improved error reporting in create_swap_partition function

## [1.0.1] - 2025-08-03

### Fixed
- Updated devices configuration format to use new list-only format
- Fixed image configuration to use proper build system
- Added build.yaml for multi-architecture support
- Corrected Dockerfile ARG handling

### Changed
- Improved Home Assistant Supervisor compatibility
- Updated base image references

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
