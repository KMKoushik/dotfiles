#!/bin/bash

# First, create the focus script
cat > /usr/local/bin/focus_script << 'EOL'
#!/bin/bash

HOSTS_FILE="/etc/hosts"
BACKUP_FILE="/etc/hosts.backup"
SITES=(
    "twitter.com"
    "www.twitter.com"
    "facebook.com"
    "www.facebook.com"
    "instagram.com"
    "www.instagram.com"
    "x.com"
    "www.x.com"
    "youtube.com"
    "www.youtube.com"    
)

enable_focus() {
    if [ ! -f "$BACKUP_FILE" ]; then
        cp "$HOSTS_FILE" "$BACKUP_FILE"
    fi
    
    echo -e "\n# Focus Mode Blocks" >> "$HOSTS_FILE"
    for site in "${SITES[@]}"; do
        if ! grep -q "^127.0.0.1 $site" "$HOSTS_FILE"; then
            echo "127.0.0.1 $site" >> "$HOSTS_FILE"
        fi
    done
    
    dscacheutil -flushcache
    killall -HUP mDNSResponder 2>/dev/null
    echo "🎯 Focus mode enabled"
}

disable_focus() {
    if [ -f "$BACKUP_FILE" ]; then
        cp "$BACKUP_FILE" "$HOSTS_FILE"
        dscacheutil -flushcache
        killall -HUP mDNSResponder 2>/dev/null
        echo "✨ Focus mode disabled"
    else
        echo "❌ No backup file found"
    fi
}

case "$1" in
    "on")
        enable_focus
        ;;
    "off")
        disable_focus
        ;;
    *)
        echo "Usage: focus {on|off}"
        exit 1
        ;;
esac
EOL

# Make the script executable
chmod +x /usr/local/bin/focus_script

# Create a sudoers entry to allow running focus without password
echo "%admin ALL=(ALL) NOPASSWD: /usr/local/bin/focus_script" > /etc/sudoers.d/focus_script

# Set proper permissions
chmod 0440 /etc/sudoers.d/focus_script

# Create an alias script that automatically uses sudo
cat > /usr/local/bin/focus << 'EOL'
#!/bin/bash
sudo focus_script "$@"
EOL

chmod +x /usr/local/bin/focus

echo "Installation complete! You can now use:"
echo "focus on  - to enable focus mode"
echo "focus off - to disable focus mode"