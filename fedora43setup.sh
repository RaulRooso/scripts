# Exit immediately if a command exits with a non-zero status
set -e

trap 'echo "🗵 Script failed at line $LINENO"; exit 1' ERR

# Update Fedora OS
echo -e '\n\n================================== Updating OS =================================\n'
sudo dnf update -y

# GUI changes
echo -e '\n\n============================= Changing Gnome theme =============================\n'
# Change color-scheme
current_scheme=$(gsettings get org.gnome.desktop.interface color-scheme)
if [ "$current_scheme" != "'prefer-dark'" ]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    echo "☑ GNOME color scheme set to prefer-dark"
else
    echo "☑ GNOME color scheme already prefer-dark, skipping"
fi
# Change background
current_bg=$(gsettings get org.gnome.desktop.background picture-uri-dark)
target_bg="file:///usr/share/backgrounds/gnome/pixel-pusher-d.jxl"

if [ "$current_bg" != "'$target_bg'" ]; then
    gsettings set org.gnome.desktop.background picture-uri-dark "$target_bg" || echo "⚠ Background file not found, skipping"
    echo "☑ Background updated"
else
    echo "☑ Background already set, skipping"
fi
# Change system color
current_accent=$(gsettings get org.gnome.desktop.interface accent-color)
if [ "$current_accent" != "'teal'" ]; then
    gsettings set org.gnome.desktop.interface accent-color 'teal'
    echo "☑ GNOME accent color set to teal"
else
    echo "☑ GNOME accent color already teal, skipping"
fi
# Change terminal setings
echo -e '\n\n======================= Updating Ptyxis terminal setings =======================\n'
if command -v ptyxis >/dev/null 2>&1; then
    echo "☑ Ptyxis terminal detected, checking settings..."
# List profiles
PTYXIS_PROFILE=${PTYXIS_PROFILE:-$(gsettings get org.gnome.Ptyxis.Profiles list | tr -d "[],' " | cut -d' ' -f1)}
# Add terminal short-cut
# Set the custom keybindings list
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
"['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ptyxis/']"\
|| echo "⚠ Could not set short-cut list, skipping"

# Define the shortcut details
# Name
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ptyxis/ \
name 'Ptyxis Terminal' || echo "⚠ Could not set short-cut name, skipping"
# Command
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ptyxis/ \
command 'ptyxis' || echo "⚠ Could not set keybinding, skipping"
# Shortcut
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ptyxis/ \
binding '<Ctrl><Alt>T' || echo "⚠ Could not set keyboard short-cut, skipping"

# Change terminal transparency
    current_opacity=$(gsettings get org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/$PTYXIS_PROFILE/ opacity)
    if [ "$current_opacity" != "0.9" ]; then
        gsettings set org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/$PTYXIS_PROFILE/ opacity 0.9
        echo "☑ Terminal opacity updated"
    else
        echo "☑ Terminal opacity already set, skipping"
    fi
# Change terminal cursor
current_cursor=$(gsettings get org.gnome.Ptyxis cursor-shape)
    if [ "$current_cursor" != "'ibeam'" ]; then
        gsettings set org.gnome.Ptyxis cursor-shape 'ibeam'
        echo "☑ Terminal cursor updated"
    else
        echo "☑ Terminal cursor already ibeam, skipping"
    fi
else
    echo "⚠ Ptyxis terminal not found, skipping terminal customization"
fi

#Install git
echo -e '\n\n================================ Installing git ================================\n'
if command -v git >/dev/null 2>&1; then
    echo "☑ Git is already installed, skipping"
else
    sudo dnf install -y git
fi
# git config --global user.name "Your Name"
# git config --global user.email "you@example.com"

#Install curl
echo -e '\n\n================================ Installing curl ===============================\n'
if command -v curl >/dev/null 2>&1; then
    echo "☑ Curl is already installed, skipping"
else
    sudo dnf install -y curl
fi


#Install unzip
echo -e '\n\n=============================== Installing unzip ===============================\n'
if command -v unzip >/dev/null 2>&1; then
    echo "☑ Unzip is already installed, skipping"
else
    sudo dnf install -y unzip
fi

#Install VS code
echo -e '\n\n============================== Installing VS code ==============================\n'
if command -v code >/dev/null 2>&1; then
    echo "☑ VS Code is already installed, skipping"
else
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'cat > /etc/yum.repos.d/vscode.repo <<EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF'
    sudo dnf install -y code
fi

#Install Node
echo -e '\n\n=============================== Installing nodejs ==============================\n'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if command -v node >/dev/null 2>&1; then
    echo "☑ Node is already installed, skipping"
else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
fi

#Install bun
echo -e '\n\n=============================== Installing bunjs ===============================\n'
if [ -x "$HOME/.bun/bin/bun" ]; then
    echo "☑ Bun is already installed, skipping"
    export PATH="$HOME/.bun/bin:$PATH"
else
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
fi
# Update system
echo -e '\n\n================================ Updating system ===============================\n'
# Update Fedora OS
sudo dnf upgrade --refresh -y
# Update hardware firmware
sudo fwupdmgr update -y || echo "⚠ No firmware updates available or not supported, skipping"

#Check for versions
echo -e '\n\n============================== Installed programs ==============================\n'
echo 'Git version:'
if command -v git >/dev/null 2>&1; then
    git --version
else
    echo "⚠ Git not found"
fi
echo '--------------------------------------------------------------------------------'
echo 'Curl version:'
if command -v curl >/dev/null 2>&1; then
    curl --version | head -n 1
else
    echo "⚠ Curl not found"
fi
echo '--------------------------------------------------------------------------------'
echo 'Unzip version:'
if command -v unzip >/dev/null 2>&1; then
    unzip -v | head -n 1
else
    echo "⚠ unzip not found"
fi
echo '--------------------------------------------------------------------------------'
echo 'VS code version:'
if command -v code >/dev/null 2>&1; then
    code --version | head -n 1
else
    echo "⚠ VS Code not found"
fi
echo '--------------------------------------------------------------------------------'
echo 'Node version:'
if command -v node >/dev/null 2>&1; then
    node --version
else
    echo "⚠ Node not found"
fi
echo '--------------------------------------------------------------------------------'
echo 'Bun version:'
if command -v bun >/dev/null 2>&1; then
    bun --version
else
    echo "⚠ Use bun-js.bun if bun is not recognized"
fi
echo '--------------------------------------------------------------------------------'
echo -e "\n⚠ Setup complete. It's recommended to reboot the system to apply all changes:\n
sudo reboot\n"
#--------------------------------------------------------------------------------
#To make this script executable run this command: chmod +x fedora43setup.sh
# then run ./fedora43setup.sh
#--------------------------------------------------------------------------------

