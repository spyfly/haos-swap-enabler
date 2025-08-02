#!/bin/bash

# HAOS Swap Enabler - Privileged Test Script
# This script runs the addon in a privileged container for testing

set -e

echo "=== HAOS Swap Enabler - Privileged Test ==="
echo

# Check if Docker is available
if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker is required for testing"
    exit 1
fi

# Build the addon container
echo "🏗️  Building addon container..."
docker build -t haos-swap-enabler:test .

# Test configurations
declare -A TEST_CONFIGS
TEST_CONFIGS[auto_discover]='{"device": "/dev/sdb", "auto_discover": true, "create_partition": false, "priority": 10}'
TEST_CONFIGS[manual_device]='{"device": "/dev/sdb", "auto_discover": false, "create_partition": false, "priority": 10}'
TEST_CONFIGS[create_partition]='{"device": "/dev/sdb", "auto_discover": false, "create_partition": true, "priority": 10}'

# Function to run addon with specific config
run_addon_test() {
    local test_name="$1"
    local config_json="$2"
    
    echo
    echo "🧪 Testing configuration: $test_name"
    echo "📋 Config: $config_json"
    echo "----------------------------------------"
    
    # Create a temporary config file
    local temp_config="/tmp/addon_config_$test_name.json"
    echo "$config_json" > "$temp_config"
    
    # Run the container with full privileges and host access
    docker run --rm -it \
        --privileged \
        --pid=host \
        --network=host \
        --volume /dev:/dev \
        --volume /proc:/proc \
        --volume /sys:/sys \
        --volume "$temp_config:/data/options.json:ro" \
        --env SUPERVISOR_TOKEN="test_token" \
        haos-swap-enabler:test \
        /bin/bash -c "
            # Mock bashio functions for testing
            bashio::config() {
                local key=\"\$1\"
                local default=\"\$2\"
                case \"\$key\" in
                    'device') echo '/dev/sdb' ;;
                    'auto_discover') jq -r '.auto_discover // true' /data/options.json ;;
                    'create_partition') jq -r '.create_partition // false' /data/options.json ;;
                    'priority') jq -r '.priority // 10' /data/options.json ;;
                    *) echo \"\$default\" ;;
                esac
            }
            export -f bashio::config
            
            # Show current system state
            echo '=== Current Block Devices ==='
            lsblk
            echo
            echo '=== Current Swap Status ==='
            swapon -s || echo 'No swap active'
            echo
            echo '=== Available Swap Partitions ==='
            blkid -t TYPE=swap -o device 2>/dev/null || echo 'No swap partitions found'
            echo
            
            # Run the addon script
            echo '=== Running Addon Script ==='
            /run.sh
        "
    
    # Cleanup
    rm -f "$temp_config"
}

# Interactive mode
interactive_test() {
    echo "🔧 Interactive Test Mode"
    echo "You can now run commands interactively in the privileged container"
    echo
    
    docker run --rm -it \
        --privileged \
        --pid=host \
        --network=host \
        --volume /dev:/dev \
        --volume /proc:/proc \
        --volume /sys:/sys \
        --volume "$(pwd)/run.sh:/run.sh:ro" \
        haos-swap-enabler:test \
        /bin/bash -c "
            echo 'Available commands:'
            echo '  lsblk                    - List block devices'
            echo '  swapon -s               - Show active swap'
            echo '  blkid -t TYPE=swap      - Find swap partitions'
            echo '  /run.sh                 - Run addon (need to set env vars)'
            echo '  exit                    - Exit container'
            echo
            /bin/bash
        "
}

# Main menu
echo "Select test mode:"
echo "1) Auto-discover test"
echo "2) Manual device test"
echo "3) Create partition test (⚠️ DANGEROUS)"
echo "4) Interactive mode"
echo "5) Show current system state"
echo "6) Exit"
echo

read -p "Enter choice (1-6): " choice

case $choice in
    1)
        run_addon_test "auto_discover" "${TEST_CONFIGS[auto_discover]}"
        ;;
    2)
        run_addon_test "manual_device" "${TEST_CONFIGS[manual_device]}"
        ;;
    3)
        echo "⚠️  WARNING: This test may create partitions and erase data!"
        read -p "Are you sure? (yes/no): " confirm
        if [[ "$confirm" == "yes" ]]; then
            run_addon_test "create_partition" "${TEST_CONFIGS[create_partition]}"
        else
            echo "Test cancelled."
        fi
        ;;
    4)
        interactive_test
        ;;
    5)
        echo "🔍 Current System State:"
        echo "----------------------------------------"
        echo "Block devices:"
        lsblk || echo "lsblk not available"
        echo
        echo "Active swap:"
        swapon -s || echo "No swap active or swapon not available"
        echo
        echo "Swap partitions:"
        blkid -t TYPE=swap -o device 2>/dev/null || echo "No swap partitions found or blkid not available"
        ;;
    6)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo
echo "✅ Test completed!"
