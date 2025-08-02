# HAOS Swap Enabler Documentation

## Configuration Options

### device
- **Type**: string
- **Default**: "/dev/sdb"
- **Description**: The block device path where swap should be enabled
- **Examples**: 
  - `/dev/sdb` - Second SATA/USB drive
  - `/dev/nvme0n1` - First NVMe drive
  - `/dev/sdb1` - Specific partition on second drive
  - `/dev/mmcblk1` - Second eMMC device

### auto_discover
- **Type**: boolean
- **Default**: true
- **Description**: Automatically discover and use existing swap partitions
- **Details**: 
  - When enabled, the addon scans all block devices for existing swap partitions
  - If found, uses the first available swap partition
  - Overrides the `device` setting when swap partitions are discovered

### create_partition
- **Type**: boolean
- **Default**: false
- **Description**: Allow automatic creation of swap partitions
- **Safety**: 
  - Only creates partitions on completely unpartitioned devices
  - Will NOT overwrite existing partitions
  - Creates a single partition using the entire device
  - Formats the partition with swap filesystem

### priority
- **Type**: integer
- **Range**: 1-32767
- **Default**: 10
- **Description**: Swap priority for the Linux kernel
- **Details**:
  - Lower numbers mean higher priority
  - Multiple swap devices can have different priorities
  - Kernel uses higher priority swaps first
  - Typical values: 1-100

## Usage Examples

### Scenario 1: First-Time Setup with Auto-Discovery
If you're not sure what devices are available:

```yaml
device: "/dev/sdb"
auto_discover: true
create_partition: false
priority: 10
```

The addon will scan for existing swap partitions and use them if found. Check the logs to see what devices are available.

### Scenario 2: Create Swap on New USB Drive
You have a new USB drive you want to dedicate to swap:

```yaml
device: "/dev/sdb"
auto_discover: false
create_partition: true
priority: 5
```

**WARNING**: This will erase all data on `/dev/sdb`!

### Scenario 3: Use Existing Swap Partition
You've manually created a swap partition:

```yaml
device: "/dev/sdb1"
auto_discover: false
create_partition: false
priority: 10
```

### Scenario 4: Multiple Swap Devices
Run the addon multiple times with different configurations to enable multiple swap devices with different priorities:

First device (high priority):
```yaml
device: "/dev/sdb1"
auto_discover: false
create_partition: false
priority: 1
```

Second device (lower priority):
```yaml
device: "/dev/sdc1"
auto_discover: false
create_partition: false
priority: 10
```

## Device Identification

### Finding Your Devices
To identify available devices, enable auto-discovery mode and check the addon logs. The addon will list all available block devices.

### Common Device Patterns
- **SATA/SCSI drives**: `/dev/sda`, `/dev/sdb`, `/dev/sdc`
- **NVMe drives**: `/dev/nvme0n1`, `/dev/nvme1n1`
- **USB drives**: Usually `/dev/sdb`, `/dev/sdc` (varies by system)
- **eMMC/SD cards**: `/dev/mmcblk0`, `/dev/mmcblk1`
- **Partitions**: Add partition number (e.g., `/dev/sdb1`, `/dev/nvme0n1p1`)

## Troubleshooting

### Error: "Block device does not exist"
- Check device is properly connected
- Verify device path is correct
- Use auto-discovery to see available devices

### Error: "Device already has partitions"
- Set `create_partition: false`
- Manually specify the partition (e.g., `/dev/sdb1`)
- Or manually prepare the device

### Error: "Failed to enable swap"
- Check device has swap filesystem: `blkid /dev/sdb1`
- Manually create swap: `mkswap /dev/sdb1`
- Verify device permissions

### Performance Issues
- Use faster storage devices (SSD vs USB 2.0)
- Adjust swap priority
- Consider device wear for flash storage

## Best Practices

1. **Use Dedicated Devices**: Avoid sharing swap devices with other data
2. **Consider Performance**: SSDs provide better swap performance than USB drives
3. **Monitor Wear**: Flash storage has limited write cycles
4. **Test Configuration**: Use auto-discovery first to understand your system
5. **Backup First**: Always backup important data before creating partitions

## Technical Details

### Required Privileges
The addon needs:
- `SYS_ADMIN` capability for mount operations
- Access to `/dev` for block device operations

### Tools Used
- `lsblk`: List block devices
- `blkid`: Identify filesystem types
- `parted`: Partition management
- `mkswap`: Create swap filesystem
- `swapon`/`swapoff`: Enable/disable swap

### Safety Mechanisms
- Checks for existing partitions before creating new ones
- Validates device existence before operations
- Comprehensive error handling and logging
- Read-only operations when possible
