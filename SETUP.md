# HAOS Swap Enabler - Setup Guide

## Quick Start

This Home Assistant addon enables swap partitions on block devices (like `/dev/sdb`) instead of using swap files. This approach offers better performance and more control over swap management.

## Prerequisites

- Home Assistant OS (HAOS) installation
- Block device available for swap (USB drive, additional SSD, etc.)
- Supervisor access in Home Assistant

## Installation Methods

### Method 1: Local Repository (Development/Testing)

1. **Copy addon files** to your Home Assistant system:
   ```bash
   # Copy the entire addon directory to your Home Assistant addons folder
   scp -r /Users/sebastian/Projekte/haos-swap-enabler/ root@YOUR_HA_IP:/addons/
   ```

2. **Access Home Assistant** and go to:
   - Settings → Add-ons → Add-on Store
   - Click the three dots (⋮) → Repositories
   - Add local repository path: `/addons/haos-swap-enabler`

### Method 2: GitHub Repository (Recommended)

1. **Create a GitHub repository**:
   ```bash
   cd /Users/sebastian/Projekte/haos-swap-enabler
   git init
   git add .
   git commit -m "Initial release of HAOS Swap Enabler v1.0.0"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/haos-swap-enabler.git
   git push -u origin main
   ```

2. **Add repository to Home Assistant**:
   - Settings → Add-ons → Add-on Store
   - Click the three dots (⋮) → Repositories  
   - Add repository URL: `https://github.com/YOUR_USERNAME/haos-swap-enabler`

## Configuration Examples

### Basic Auto-Discovery (Recommended for beginners)
```yaml
device: "/dev/sdb"
auto_discover: true
create_partition: false
priority: 10
```

### Create New Swap Partition (Will erase device!)
```yaml
device: "/dev/sdb"
auto_discover: false
create_partition: true
priority: 10
```

### Use Specific Existing Partition
```yaml
device: "/dev/sdb1"
auto_discover: false
create_partition: false
priority: 10
```

## Safety Checklist

Before running the addon:

1. **Backup Important Data**: The addon can create partitions which will erase devices
2. **Verify Device Path**: Use auto-discovery first to see available devices
3. **Check Device Usage**: Ensure the device isn't being used for other purposes
4. **Test Configuration**: Start with auto-discovery mode

## Troubleshooting

### Common Issues

1. **"Block device does not exist"**
   - Enable auto-discovery to see available devices
   - Check device is properly connected
   - Verify device path in system logs

2. **"Permission denied"**
   - Addon should have required privileges automatically
   - Check Home Assistant system logs

3. **"Device already has partitions"**
   - Use existing partition path (e.g., `/dev/sdb1`)
   - Or manually prepare the device first

### Checking Available Devices

Enable auto-discovery and check the addon logs to see what devices are available on your system.

## Performance Tips

- **Use SSDs** for better swap performance
- **Set appropriate priority** (lower numbers = higher priority)
- **Consider device wear** for flash storage
- **Monitor swap usage** in Home Assistant system info

## Security Notes

- Addon requires privileged access to manage block devices
- Only operates on explicitly configured devices
- Includes safety checks to prevent accidental data loss
- Review configuration carefully before enabling partition creation
