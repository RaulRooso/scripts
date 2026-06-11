#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Universal Error Trapping Mechanism
trap 'echo "🗵 Script failed at line $LINENO"; exit 1'
echo -e '\n\n=================================================|================================================\n'
# Update Fedora OS
echo -e '\n=============================================================================================================='
echo -e '                                                  Updating OS                                                 '
echo -e '=============================================================================================================='
sudo dnf update -y
# The Smart Guard: Check if a reboot is pending due to core updates
if sudo dnf needs-restarting -k >/dev/null 2>&1; then
    echo '☑ System libraries and kernel are fresh. Proceeding...'
else
    echo -e '\n⚠ A core system update (Kernel/Glibc) was just installed.'
    echo '⚠ To avoid configuration conflicts, please reboot your system now.'
    echo '⚠ After rebooting, simply run this script again to complete the setup!'
    echo '⟳ To restat, use the command: "sudo reboot".'
    exit 0
fi
# GUI changes
echo -e '\n=============================================================================================================='
echo -e '                                     Initializing Fedora KDE Workstation Setup                                '
echo -e '=============================================================================================================='

# Global Workstation Identity
GIT_USER="Your Name"
GIT_EMAIL="you@example.com"

echo "→ Setting up global Git user identity..."
if command -v git >/dev/null 2>&1; then
    git config --global user.name "$GIT_USER"
    git config --global user.email "$GIT_EMAIL"
    echo "☑ Git configuration locked: $GIT_USER <$GIT_EMAIL>"
else
    echo "⚠ Git binary not yet present; profile staging skipped for downstream native tooling block."
fi

echo -e '\n=============================================================================================================='
echo -e '                                         Customizing KDE Look & Feel                                          '
echo -e '=============================================================================================================='

# 1. Query the current active look-and-feel global theme package cleanly
current_theme=$(kreadconfig6 --file kdeglobals --group General --key LookAndFeelPackage)

# 2. Check if it's already our desired upstream Breeze Dark layout
if [ "$current_theme" != "org.kde.breezedark.desktop" ]; then
    echo "→ System layout differs. Applying native Breeze Dark structure..."
    if plasma-apply-lookandfeel -a org.kde.breezedark.desktop >/dev/null 2>&1; then
        echo "☑ KDE global theme successfully set to Breeze Dark"
    else
        echo "⚠ Failed to apply Breeze Dark theme layout"
    fi
else
    echo "☑ KDE global theme layout is already Breeze Dark, skipping"
fi

# Changing accent color
target_accent="0,128,128"
current_accent=$(kreadconfig6 --file kdeglobals --group General --key AccentColor)

if [ "$current_accent" != "$target_accent" ]; then
    echo "→ Accent color differs or is unset. Injecting Teal..."
    kwriteconfig6 --file kdeglobals --group General --key AccentColor "$target_accent"
    if plasma-apply-colorscheme BreezeDark >/dev/null 2>&1; then
        echo "☑ KDE accent color successfully set to Teal"
    else
        echo "⚠ Failed to broadcast the color refresh"
    fi
else
    echo "☑ KDE accent color is already Teal, skipping"
fi

# Changing background
target_bg="/usr/share/wallpapers/ScarletTree/contents/images_dark/5120x2880.png"
current_bg=$(kreadconfig6 --file plasmashellrc --group Wallpaper --group org.kde.image --group General --key Image)

if [ "$current_bg" != "$target_bg" ]; then
    echo "→ Background image differs or is unset. Summoning the desktop painter..."
    if plasma-apply-wallpaperimage "$target_bg" >/dev/null 2>&1; then
        echo "☑ KDE wallpaper successfully updated to ScarletTree"
    else
        echo "⚠ Failed to apply the new wallpaper image layout"
    fi
else
    echo "☑ KDE wallpaper is already ScarletTree, skipping"
fi

echo -e '\n=============================================================================================================='
echo -e '                                         Setting Terminal Shortcuts                                           '
echo -e '=============================================================================================================='

current_shortcut=$(kreadconfig6 --file kglobalshortcutsrc --group "org.kde.konsole.desktop" --key "_launch")

if [[ "$current_shortcut" != *"Ctrl+Alt+T"* ]]; then
    echo "→ Shortcut differs or is missing. Registering Ctrl+Alt+T..."
    kwriteconfig6 --file kglobalshortcutsrc --group "org.kde.konsole.desktop" --key "_launch" "Ctrl+Alt+T,none,Launch Konsole"
    if dbus-send --print-reply --dest=org.kde.KWin /component/org_kde_konsole_desktop org.kde.kglobalaccel.Component.invokeShortcut string:_launch >/dev/null 2>&1; then
        echo "☑ Global shortcut Ctrl+Alt+T successfully registered"
    else
        echo "⚠ Shortcut written, but system daemon reload failed"
    fi
else
    echo "☑ Global shortcut Ctrl+Alt+T already registered, skipping"
fi

echo -e '\n=============================================================================================================='
echo -e '                                      Creating Konsole Master Profile                                         '
echo -e '=============================================================================================================='

target_profile_name="Mainline"
profile_dir="$HOME/.local/share/konsole"
profile_file="$profile_dir/${target_profile_name}.profile"
colorscheme_file="$profile_dir/${target_profile_name}.colorscheme"

mkdir -p "$profile_dir"

if [ ! -f "$colorscheme_file" ]; then
    echo "→ Minting fresh dark color palette: [${target_profile_name}.colorscheme]..."
    cat << 'EOF' > "$colorscheme_file"
[General]
Description=Mainline
Opacity=0.7
Blur=true

[Background]
Color=30,30,30

[BackgroundIntense]
Color=45,45,45

[Foreground]
Color=240,240,240

[ForegroundIntense]
Color=255,255,255
EOF
    echo "☑ Custom terminal color scheme successfully engineered."
else
    echo "☑ Custom terminal color scheme 'Mainline' already exists, skipping creation."
fi

if [ ! -f "$profile_file" ]; then
    echo "→ Constructing complete profile geometry for '${target_profile_name}'..."
    kwriteconfig6 --file "$profile_file" --group "General" --key "Name" "$target_profile_name"
    kwriteconfig6 --file "$profile_file" --group "General" --key "Parent" "FALLBACK/"
    kwriteconfig6 --file "$profile_file" --group "Appearance" --key "ColorScheme" "$target_profile_name"
    kwriteconfig6 --file "$profile_file" --group "Cursor Options" --key "CursorShape" "1"

    echo "→ Routing system defaults to utilize the Mainline architecture..."
    kwriteconfig6 --file "konsolerc" --group "Desktop Entry" --key "DefaultProfile" "${target_profile_name}.profile"
    kwriteconfig6 --file "konsolerc" --group "Favorite Profiles" --key "Favorites" "${target_profile_name}.profile"
    echo "☑ Mainline terminal engine fully configured and set as default."
else
    echo "☑ Mainline profile configuration already structurally present, skipping creation."
fi

echo -e '\n=============================================================================================================='
echo -e '                                            Deploying Native Tooling                                          '
echo -e '=============================================================================================================='

needed_tools=("git" "curl" "unzip")
tools_to_install=()

for tool in "${needed_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "☑ Tool '$tool' is already present on the workbench, skipping"
    else
        echo "→ Tool '$tool' is missing from the system"
        tools_to_install+=("$tool")
    fi
done

if [ ${#tools_to_install[@]} -gt 0 ]; then
    echo "→ Provisioning missing tools via DNF: ${tools_to_install[*]}..."
    sudo dnf install -y "${tools_to_install[@]}"
    echo "☑ Native tools successfully deployed"
else
    echo "☑ All native utilities are fully accounted for"
fi

echo -e '\n=============================================================================================================='
echo -e '                                               Installing VS Code                                             '
echo -e '=============================================================================================================='

if command -v code >/dev/null 2>&1; then
    echo "☑ VS Code is already installed, skipping configuration and deployment"
else
    echo "→ VS Code not found. Initiating repository registration..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'cat > /etc/yum.repos.d/vscode.repo <<EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF'
    echo "→ Updating repository metadata and provisioning code package..."
    sudo dnf install -y code
    echo "☑ VS Code has been successfully installed and registered"
fi

echo -e '\n=============================================================================================================='
echo -e '                                           Installing Node.js via NVM                                         '
echo -e '=============================================================================================================='

export NVM_DIR="$HOME/.nvm"

if [ -d "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
    echo "☑ NVM architecture detected in home directory, skipping installation"
    \. "$NVM_DIR/nvm.sh"
else
    echo "→ NVM not found. Fetching official installation binary..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    echo "→ Provisioning Node.js Long Term Support (LTS) release..."
    nvm install --lts
    echo "☑ Node.js LTS has been successfully registered to NVM"
fi

echo -e '\n=============================================================================================================='
echo -e '                                         Installing Bun via Shell Engine                                      '
echo -e '=============================================================================================================='

export BUN_INSTALL="$HOME/.bun"

if [ -x "$BUN_INSTALL/bin/bun" ]; then
    echo "☑ Bun execution engine detected in user space, skipping network fetch"
    export PATH="$BUN_INSTALL/bin:$PATH"
else
    echo "→ Bun binary missing. Fetching official localized environment..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="$BUN_INSTALL/bin:$PATH"
    echo "☑ Bun utility successfully deployed to local workspace"
fi

if grep -q "BUN_INSTALL" "$HOME/.bashrc"; then
    echo "☑ Bun environment paths are already wired into ~/.bashrc"
else
    echo "→ Injecting permanent Bun paths into ~/.bashrc..."
    echo -e '\n# Bun Environment Configuration' >> "$HOME/.bashrc"
    echo 'export BUN_INSTALL="$HOME/.bun"' >> "$HOME/.bashrc"
    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> "$HOME/.bashrc"
    echo "☑ Permanent shell configuration completed."
fi

echo -e '\n=============================================================================================================='
echo -e '                                              Installing Falkon                                               '
echo -e '=============================================================================================================='

if command -v falkon >/dev/null 2>&1; then
    echo '☑ Falkon is already installed, skipping'
else
    echo "→ Provisioning Falkon browser via DNF..."
    sudo dnf install -y falkon
    echo "☑ Falkon successfully installed"
fi

echo -e '\n=============================================================================================================='
echo -e '                                          System Verification Deck                                            '
echo -e '=============================================================================================================='

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$HOME/.bun/bin:$PATH"

manifest=(
    "git:Git Version"
    "curl:Curl Version"
    "unzip:Unzip Version"
    "code:VS Code Version"
    "node:Node.js Version"
    "bun:Bun Engine Version"
    "falkon:Falkon Browser"
)

echo "--------------------------------------------------------------------------------------------------------------"
for item in "${manifest[@]}"; do
    binary="${item%%:*}"
    label="${item#*:}"

    if command -v "$binary" >/dev/null 2>&1; then
        version_info=$("$binary" --version 2>&1 | head -n 1 || "$binary" -v 2>&1 | head -n 1)
        printf "  %-22s ⇒  \e[32m%s\e[0m\n" "$label" "$version_info"
    else
        printf "  %-22s ⇒  \e[31m⚠ Not Found\e[0m\n" "$label"
    fi
    echo "--------------------------------------------------------------------------------------------------------------"
done

echo -e "\n🛈 Setup complete. Please restart your terminal tabs or run 'source ~/.bashrc' to activate all runtimes.\n"
