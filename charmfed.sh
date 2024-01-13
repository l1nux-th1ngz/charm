#!/bin/bash

# Add Charm repository
echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo

# Install mods
sudo yum install mods

# Install wishlist
sudo yum install wishlist

# Install vhs, ffmpeg
sudo yum install vhs ffmpeg

# Install glow
sudo yum install glow

# Install skate
sudo yum install skate

# Create Soft Serve directory
sudo mkdir -p /var/local/lib/soft-serve

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
