#!/bin/bash

# Quick Privileged Test for HAOS Swap Enabler
# This runs the addon directly in a privileged Alpine container with host access

set -e

echo "🚀 Running HAOS Swap Enabler in privileged mode..."
echo

# Build and run the addon container with full host access
docker run --rm -it \
    --privileged \
    --pid=host \
    --network=host \
    -v /dev:/dev:rw \
    -v /proc:/proc:rw \
    -v /sys:/sys:rw \
    -v "$(pwd)":/addon:ro \
    alpine:latest \
    sh -c '
        # Install required tools
        apk add --no-cache util-linux e2fsprogs parted lsblk blkid jq
        
        # Enter host namespace for full system access
        nsenter --target 1 --mount --uts --net --ipc sh -xec "
            echo \"=== Host System Access Established ====\"
            echo \"Current working directory: \$(pwd)\"
            echo
            
            # Show current system state
            echo \"=== Current Block Devices ====\"
            lsblk
            echo
            
            echo \"=== Current Swap Status ====\"
            swapon -s 2>/dev/null || echo \"No swap currently active\"
            echo
            
            echo \"=== Available Swap Partitions ====\"
            blkid -t TYPE=swap -o device 2>/dev/null || echo \"No swap partitions found\"
            echo
            
            # Mock bashio functions for testing
            bashio_config() {
                case \"\$1\" in
                    device) echo \"/dev/sdb\" ;;
                    auto_discover) echo \"true\" ;;
                    create_partition) echo \"false\" ;;
                    priority) echo \"10\" ;;
                    *) echo \"\${2:-}\" ;;
                esac
            }
            
            # Source the addon script with modifications
            echo \"=== Running Addon Script ====\"
            cd /addon
            
            # Replace bashio::config calls with our mock function
            sed 's/bashio::config/bashio_config/g' run.sh > /tmp/run_modified.sh
            chmod +x /tmp/run_modified.sh
            
            # Run the modified script
            /tmp/run_modified.sh
        "
    '

echo
echo "✅ Test completed!"
