# HAOS Swap Enabler Add-on for Home Assistant Operating System

This add-on enables swap partitions on block devices (like `/dev/sdb`) for Home Assistant OS systems. Unlike traditional swap file solutions, this addon works directly with swap partitions on storage devices.

## Features

- **Block Device Support**: Enable swap on any block device (e.g., `/dev/sdb`, `/dev/nvme0n1`)
- **Auto-Discovery**: Automatically detect existing swap partitions
- **Partition Creation**: Optionally create swap partitions on unpartitioned devices
- **Priority Control**: Set swap priority for multiple swap devices
- **Safety Checks**: Prevents accidental data loss on devices with existing partitions

## Installation

1. Navigate to the Supervisor panel in your Home Assistant instance
2. Click on the "Add-on store" tab
3. Add this repository URL
4. Install the "HAOS Swap Enabler" add-on

## Configuration

Configure the add-on through the Home Assistant interface with these options:

### Basic Configuration

- **device**: The block device path (e.g., `/dev/sdb`)
- **auto_discover**: Enable automatic detection of swap partitions
- **create_partition**: Allow creation of swap partitions on unpartitioned devices
- **priority**: Swap priority (1-32767, default: 10)

### Example Configurations

#### Auto-Discovery Mode (Recommended)
```yaml
device: "/dev/sdb"
auto_discover: true
create_partition: false
priority: 10
```

#### Manual Device with Partition Creation
```yaml
device: "/dev/sdb"
auto_discover: false
create_partition: true
priority: 10
```

#### Use Existing Swap Partition
```yaml
device: "/dev/sdb1"
auto_discover: false
create_partition: false
priority: 10
```

## How It Works

1. **Discovery Phase**: If auto-discovery is enabled, the addon scans for existing swap partitions
2. **Device Validation**: Checks if the specified device exists and is accessible
3. **Partition Management**: Creates swap partition if requested and safe to do so
4. **Swap Activation**: Enables swap with the specified priority
5. **Status Reporting**: Shows current swap configuration

## Safety Features

- **Existing Data Protection**: Won't create partitions on devices that already have partitions
- **Device Validation**: Ensures specified devices exist before attempting operations
- **Swap Detection**: Automatically detects existing swap signatures
- **Error Handling**: Comprehensive error checking and reporting

## Supported Devices

- USB storage devices (`/dev/sdb`, `/dev/sdc`, etc.)
- NVMe drives (`/dev/nvme0n1`, `/dev/nvme1n1`, etc.)
- SATA drives (`/dev/sda`, `/dev/sdb`, etc.)
- eMMC devices (`/dev/mmcblk0`, `/dev/mmcblk1`, etc.)

## Troubleshooting

### Common Issues

1. **Device not found**: Ensure the device is properly connected and recognized by the system
2. **Permission denied**: The addon runs with required privileges automatically
3. **Partition creation failed**: Check if the device already has partitions
4. **Swap activation failed**: Verify the device has a valid swap signature

### Checking Device Status

Use the auto-discovery mode to see available devices and their current status. The addon will list all suitable block devices in the logs.

### Manual Partition Preparation

If you prefer to prepare partitions manually:

```bash
# Create partition table (WARNING: This will erase the device!)
parted /dev/sdb mklabel gpt

# Create swap partition using full device
parted /dev/sdb mkpart primary linux-swap 0% 100%

# Create swap filesystem
mkswap /dev/sdb1
```

## Add-on Behavior

- **Startup**: Runs once at startup to enable configured swap
- **Auto-boot**: Enabled by default to ensure swap is available on system restart
- **One-time Operation**: Stops after completing swap setup
- **Logging**: Provides detailed logs for troubleshooting

## Performance Considerations

- **Priority**: Higher priority swaps are used first (lower numbers = higher priority)
- **Device Speed**: Faster storage devices provide better swap performance
- **Size**: Swap size is determined by the partition size you create

## Security Notes

- Requires privileged access to manage block devices
- Only operates on devices explicitly configured
- Includes safety checks to prevent accidental data loss

## Credits

Inspired by the swap file solutions in the Home Assistant community, adapted to work with block devices and partitions for better performance and flexibility.
