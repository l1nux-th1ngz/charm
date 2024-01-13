#!/bin/bash

# Give full root access
su
visudo
adduser <username> sudo
usermod -aG sudo username
username ALL=(ALL) ALL

# Set up Charm repository for apt
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list

# Install mods
sudo apt update && sudo apt install mods

# Install wishlist
sudo apt update && sudo apt install wishlist

# Install vhs, ffmpeg
sudo apt update && sudo apt install vhs ffmpeg

# Install soft-serve
sudo apt update && sudo apt install soft-serve

# Install glow
sudo apt update && sudo apt install glow

# Install skate
sudo apt update && sudo apt install skate

# Configure SSH for root login
sudo nano /etc/ssh/sshd_config
# Add the line: PermitRootLogin yes
# Save and exit

# Restart SSH service
sudo service ssh restart

# Set up Charm repository for yum
echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo

# Install soft-serve using yum
sudo yum install soft-serve

# Write Soft Serve systemd service file
sudo tee /etc/systemd/system/soft-serve.service > /dev/null <<EOL
[Unit]
Description=Soft Serve git server 🍦
Documentation=https://github.com/charmbracelet/soft-serve
Requires=network-online.target
After=network-online.target

[Service]
Type=simple
Restart=always
RestartSec=1
ExecStart=/usr/bin/soft serve
Environment=SOFT_SERVE_DATA_PATH=/var/local/lib/soft-serve
EnvironmentFile=-/etc/soft-serve.conf
WorkingDirectory=/var/local/lib/soft-serve

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable Soft Serve to start on-boot
sudo systemctl enable soft-serve.service

# Start Soft Serve now!!
sudo systemctl start soft-serve.service
