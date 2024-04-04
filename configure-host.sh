#!/bin/bash

# Modification log functionality
log_changes() {
    if [ "$VERBOSE" = true ]; then
        echo "$1"
    fi
    logger -t configure-host.sh "$1"
}

# Function to update /etc/hosts file
update_hosts_file() {
    if ! grep -q "$2.*$1" /etc/hosts; then
        echo "$2 $1" | sudo tee -a /etc/hosts >/dev/null
        log_changes "Updated /etc/hosts file with entry: $2 $1"
    fi
}

# Function to update /etc/hostname file
update_hostname_file() {
    if [ "$1" != "$(hostname)" ]; then
        echo "$1" | sudo tee /etc/hostname >/dev/null
        log_changes "Updated hostname to: $1"
    fi
}

# Function to update netplan configuration
update_netplan() {
    if ! grep -q "addresses: \[$2/24\]" /etc/netplan/*.yaml; then
        sed -i "/addresses:/a \ \ \ \  $2/24" /etc/netplan/*.yaml
        netplan apply
        log_changes "Updated netplan configuration with IP address: $2"
    fi
}

# Initialize variables
VERBOSE=false

# Ignore TERM, HUP and INT signals
trap '' TERM HUP INT

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -verbose)
            VERBOSE=true
            shift
            ;;
        -name)
            DESIRED_NAME="$2"
            update_hostname_file "$DESIRED_NAME"
            update_hosts_file "$DESIRED_NAME" "$(hostname -I | awk '{print $1}')"
            shift 2
            ;;
        -ip)
            DESIRED_IP="$2"
            update_hosts_file "$(hostname)" "$DESIRED_IP"
            update_netplan "$(hostname -I | awk '{print $1}')" "$DESIRED_IP"
            shift 2
            ;;
        -hostentry)
            DESIRED_NAME="$2"
            DESIRED_IP="$3"
            update_hosts_file "$DESIRED_NAME" "$DESIRED_IP"
            shift 3
            ;;
        *)
            echo "Invalid argument: $1"
            exit 1
            ;;
    esac
done

exit 0
