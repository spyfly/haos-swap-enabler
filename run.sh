#!/command/with-contenv bashio
# shellcheck shell=bash

set -e

# Get configuration
DEVICE=$(bashio::config 'device')
AUTO_DISCOVER=$(bashio::config 'auto_discover')
CREATE_PARTITION=$(bashio::config 'create_partition')
PRIORITY=$(bashio::config 'priority' 10)

print_date() {
  timestamp=$(date +'%H:%M:%S %d/%m/%Y')
  echo "[$timestamp] $1"
}

check_device_exists() {
  local device=$1
  if [[ ! -b "$device" ]]; then
    print_date "ERROR: Block device $device does not exist!"
    return 1
  fi
  return 0
}

get_available_devices() {
  # List all available block devices excluding system devices
  lsblk -dpno NAME,SIZE,TYPE | grep -E "disk|part" | grep -v "/dev/loop" | grep -v "/dev/ram" | while read -r name size type; do
    # Skip if device is already mounted or in use
    if ! mount | grep -q "$name" && ! swapon -s | grep -q "$name"; then
      echo "$name ($size, $type)"
    fi
  done
}

discover_swap_devices() {
  print_date "Discovering available swap devices..."
  
  # Look for existing swap partitions
  local swap_partitions
  swap_partitions=$(blkid -t TYPE=swap -o device 2>/dev/null || true)
  
  if [[ -n "$swap_partitions" ]]; then
    print_date "Found existing swap partitions:"
    echo "$swap_partitions" | while read -r partition; do
      if [[ -b "$partition" ]]; then
        local size
        size=$(lsblk -dnbo SIZE "$partition" 2>/dev/null || echo "unknown")
        print_date "  - $partition (Size: $size)"
      fi
    done
    return 0
  fi
  
  print_date "No existing swap partitions found."
  print_date "Available block devices:"
  get_available_devices | while read -r device_info; do
    print_date "  - $device_info"
  done
  return 1
}

create_swap_partition() {
  local device=$1
  print_date "Creating swap partition on $device..."
  
  # Check if device has existing partitions
  local existing_parts
  existing_parts=$(lsblk -rno NAME "$device" | tail -n +2 | wc -l)
  
  if [[ "$existing_parts" -gt 0 ]]; then
    print_date "WARNING: Device $device already has partitions. Skipping partition creation for safety."
    print_date "Existing partitions:"
    lsblk "$device"
    return 1
  fi
  
  # Create a single partition that uses the entire device
  print_date "Creating partition table and swap partition..."
  parted -s "$device" mklabel gpt
  parted -s "$device" mkpart primary linux-swap 0% 100%
  
  # Get the new partition name
  local partition="${device}1"
  if [[ ! -b "$partition" ]]; then
    # For some devices, partition might be named differently
    partition="${device}p1"
  fi
  
  if [[ ! -b "$partition" ]]; then
    print_date "ERROR: Failed to create partition on $device"
    return 1
  fi
  
  print_date "Created partition: $partition"
  
  # Create swap filesystem
  print_date "Creating swap filesystem on $partition..."
  mkswap "$partition"
  
  print_date "Swap partition created successfully: $partition"
  echo "$partition"
}

enable_swap() {
  local device=$1
  local priority=${2:-10}
  
  print_date "Enabling swap on $device with priority $priority..."
  
  # Check if it's already enabled
  if swapon -s | grep -q "$device"; then
    print_date "Swap on $device is already enabled."
    return 0
  fi
  
  # Check if device has swap signature
  if ! blkid -t TYPE=swap "$device" >/dev/null 2>&1; then
    print_date "Device $device does not have swap signature. Creating swap filesystem..."
    mkswap "$device"
  fi
  
  # Enable swap with priority
  swapon -p "$priority" "$device"
  
  if swapon -s | grep -q "$device"; then
    local size
    size=$(lsblk -dnbo SIZE "$device" 2>/dev/null || echo "unknown")
    print_date "Swap successfully enabled on $device (Size: $size, Priority: $priority)"
    return 0
  else
    print_date "ERROR: Failed to enable swap on $device"
    return 1
  fi
}

main() {
  print_date "Starting HAOS Swap Enabler add-on..."
  print_date "Configuration:"
  print_date "  Device: $DEVICE"
  print_date "  Auto-discover: $AUTO_DISCOVER"
  print_date "  Create partition: $CREATE_PARTITION"
  print_date "  Priority: $PRIORITY"
  
  # Show current swap status
  print_date "Current swap status:"
  if swapon -s | grep -v "Filename"; then
    swapon -s
  else
    print_date "  No swap currently enabled"
  fi
  
  if [[ "$AUTO_DISCOVER" == "true" ]]; then
    print_date "Auto-discovery mode enabled"
    if discover_swap_devices; then
      # Use the first discovered swap partition
      local swap_device
      swap_device=$(blkid -t TYPE=swap -o device 2>/dev/null | head -n1)
      if [[ -n "$swap_device" ]]; then
        print_date "Using discovered swap device: $swap_device"
        enable_swap "$swap_device" "$PRIORITY"
      fi
    else
      print_date "No swap devices discovered. Please configure manually or enable partition creation."
    fi
  else
    # Manual device configuration
    if ! check_device_exists "$DEVICE"; then
      print_date "Specified device $DEVICE not found."
      exit 1
    fi
    
    # Check if device is a swap partition
    if blkid -t TYPE=swap "$DEVICE" >/dev/null 2>&1; then
      print_date "Device $DEVICE is already a swap partition"
      enable_swap "$DEVICE" "$PRIORITY"
    elif [[ "$CREATE_PARTITION" == "true" ]]; then
      print_date "Device $DEVICE is not a swap partition. Creating swap partition..."
      local new_partition
      new_partition=$(create_swap_partition "$DEVICE")
      if [[ $? -eq 0 && -n "$new_partition" ]]; then
        enable_swap "$new_partition" "$PRIORITY"
      else
        print_date "Failed to create swap partition"
        exit 1
      fi
    else
      print_date "Device $DEVICE is not a swap partition and partition creation is disabled."
      print_date "Either:"
      print_date "  1. Set create_partition to true to automatically create a swap partition"
      print_date "  2. Manually create a swap partition on the device"
      print_date "  3. Specify a device that already has a swap partition"
      exit 1
    fi
  fi
  
  print_date "Final swap status:"
  swapon -s
  
  print_date "HAOS Swap Enabler completed successfully."
}

# Run main function
main
