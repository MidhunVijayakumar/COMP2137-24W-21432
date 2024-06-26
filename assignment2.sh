#!/bin/bash

# Check netplan configuration
if ! grep -q "192.168.16.21" /etc/netplan/01-netcfg.yaml || ! grep -q "nameservers" /etc/netplan/01-netcfg.yaml; then
    echo "Netplan configuration is not correct."
    echo "Please update the netplan configuration file and ensure that the /etc/hosts file has the correct IP address."
    exit 1
fi

# Check if Apache2 and Squid are installed
if ! command -v apache2 || ! command -v squid; then
    echo "Apache2 or Squid is not installed."
    exit 1
fi

# Check if Apache2 and Squid are running
if ! systemctl is-active --quiet apache2 || ! systemctl is-active --quiet squid; then
    echo "Apache2 or Squid is not running."
    exit 1
fi

# Check ufw configuration
if ! ufw status | grep -q "Status: active" || ! ufw status | grep -q "22/tcp" || ! ufw status | grep -q "80/tcp" || ! ufw status | grep -q "3128/tcp" || ! ufw status | grep -q "192.168.16.0/24 allow 22"; then
    echo "Firewall configuration is not correct."
    exit 1
fi

# Check users' home directories, default shells, and SSH keys
for user in dennis aubrey captain snibbles brownie scooter sandy perrier cindy tiger yoda; do
    if id -u "$user" >/dev/null 2>&1; then
        if ! grep -q "/home/$user" /etc/passwd || ! grep -q "/bin/bash" /etc/passwd <<<"$user" || ! grep -q "^$user:" /root/.ssh/authorized_keys || ! grep -q "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" /home/"$user"/.ssh/authorized_keys; then
            echo "User configuration is not correct for user: $user"
            exit 1
        fi
    fi
done

# If no issues are found, the configuration is correct.
echo "The configuration is correct."
exit 0
