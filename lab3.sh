#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 [-verbose]"
    exit 1
}

# Check for verbose mode
if [ "$1" == "-verbose" ]; then
    VERBOSE=true
elif [ "$1" != "" ]; then
    usage
fi

# Function to run configure-host.sh remotely
run_remote_script() {
    local server="$1"
    local name="$2"
    local ip="$3"
    local hostentry_name="$4"
    local hostentry_ip="$5"
    local ssh_command="ssh remoteadmin@$server -- /root/configure-host.sh"

    if [ "$VERBOSE" = true ]; then
        ssh_command+=" -verbose"
    fi

    ssh_command+=" -name $name -ip $ip -hostentry $hostentry_name $hostentry_ip"

    if [ "$VERBOSE" = true ]; then
        echo "Running command on $server: $ssh_command"
    fi

    $ssh_command
}

# Transfer configure-host.sh to servers and run it
scp configure-host.sh remoteadmin@server1-mgmt:/root
run_remote_script "server1-mgmt" "loghost" "192.168.16.3" "webhost" "192.168.16.4"

scp configure-host.sh remoteadmin@server2-mgmt:/root
run_remote_script "server2-mgmt" "webhost" "192.168.16.4" "loghost" "192.168.16.3"

# Update local /etc/hosts file
./configure-host.sh -hostentry loghost 192.168.16.3
./configure-host.sh -hostentry webhost 192.168.16.4
#sudo awk '{if($1=="192.168.16.200") {$1="192.168.16.3"}}' /etc/hosts
#sudo awk '{if($1=="192.168.16.201") {$1="192.168.16.4"}}' /etc/hosts
