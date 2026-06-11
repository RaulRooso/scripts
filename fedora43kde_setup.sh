# Exit immediately if a command exits with a non-zero status
set -e

trap 'echo "🗵 Script failed at line $LINENO"; exit 1' ERR
echo -e '\n\n=================================================|================================================\n'
# # Update Fedora OS
# echo -e '\n\n=========================================== Updating OS ==========================================\n'
# sudo dnf update -y
# # The Smart Guard: Check if a reboot is pending due to core updates
# if sudo dnf needs-restarting -k >/dev/null 2>&1; then
#     echo '☑ System libraries and kernel are fresh. Proceeding...'
# else
#     echo -e '\n⚠ A core system update (Kernel/Glibc) was just installed.'
#     echo '⚠ To avoid configuration conflicts, please reboot your system now.'
#     echo '⚠ After rebooting, simply run this script again to complete the setup!'
#     echo '⟳ To restat, use the command: "sudo reboot".'
#     exit 0
# fi
# GUI changes

# Exit immediately if a command exits with a non-zero status
set -e

trap 'echo "🗵 Script failed at line $LINENO"; exit 1' ERR

# GUI changes
echo -e '\n\n=================================== Customizing KDE Look & Feel ==================================\n'

# Change color-scheme
current_theme=$(kreadconfig6 --file kdeglobals --group General --key LookAndFeelPackage)

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

echo -e '\n\n=================================== Setting Terminal Shortcuts ===================================\n'
# 1. Read the current shortcut assigned to launch Konsole
current_shortcut=$(kreadconfig6 --file kglobalshortcutsrc --group "org.kde.konsole.desktop" --key "_launch")
echo "Diagnostic: Current Konsole shortcut is set to [$current_shortcut]"
# 2. Check if it matches our target shortcut
if [[ "$current_shortcut" != *"Ctrl+Alt+T"* ]]; then
    echo "→ Shortcut differs or is missing. Registering Ctrl+Alt+T..."
    # Write the shortcut rule to the global shortcuts configuration file
    kwriteconfig6 --file kglobalshortcutsrc --group "org.kde.konsole.desktop" --key "_launch" "Ctrl+Alt+T,none,Launch Konsole"
    # Reload the global shortcut daemon over DBus so it takes effect instantly
    if dbus-send --print-reply --dest=org.kde.KWin /component/org_kde_konsole_desktop org.kde.kglobalaccel.Component.invokeShortcut string:_launch >/dev/null 2>&1; then
        echo "☑ Global shortcut Ctrl+Alt+T successfully registered"
    else
        echo "⚠ Shortcut written, but system daemon reload failed"
    fi
else
    echo "☑ Global shortcut Ctrl+Alt+T already registered, skipping"
fi

echo -e '\n\n================================ Creating Konsole Master Profile =================================\n'

# 1. Define our structural paths
target_profile_name="Mainline"
profile_dir="$HOME/.local/share/konsole"
profile_file="$profile_dir/${target_profile_name}.profile"
colorscheme_file="$profile_dir/${target_profile_name}.colorscheme"

# Ensure the local configuration vault physically exists
mkdir -p "$profile_dir"

# 2. Mint the Bespoke Paint Scheme (0.7 Opacity + Blur Engine)
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

# 3. Construct the clean Profile file in a single, predictable block
if [ ! -f "$profile_file" ]; then
    echo "→ Constructing complete profile geometry for '${target_profile_name}'..."

    # Core Meta Properties
    kwriteconfig6 --file "$profile_file" --group "General" --key "Name" "$target_profile_name"
    kwriteconfig6 --file "$profile_file" --group "General" --key "Parent" "FALLBACK/"

    # Appearance Linkage
    kwriteconfig6 --file "$profile_file" --group "Appearance" --key "ColorScheme" "$target_profile_name"

    # The Interrogated Cursor Attributes (The true vertical I-Beam line)
    kwriteconfig6 --file "$profile_file" --group "Cursor Options" --key "CursorShape" "1"

    # 4. Execute Master System Handshake for global application defaults
    echo "→ Routing system defaults to utilize the Mainline architecture..."
    kwriteconfig6 --file "konsolerc" --group "Desktop Entry" --key "DefaultProfile" "${target_profile_name}.profile"
    kwriteconfig6 --file "konsolerc" --group "Favorite Profiles" --key "Favorites" "${target_profile_name}.profile"

    echo "☑ Mainline terminal engine fully configured and set as default."
else
    echo "☑ Mainline profile configuration already structurally present, skipping creation."
fi

#Install sofware

echo -e '\n\n==================================== Deploying Native Tooling ====================================\n'

# 1. Define the essential hand tools required for the environment
needed_tools=("git" "curl" "unzip")
tools_to_install=()

# 2. Inspect the workbench to see what is already present
for tool in "${needed_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "☑ Tool '$tool' is already present on the workbench, skipping"
    else
        echo "→ Tool '$tool' is missing from the system"
        tools_to_install+=("$tool")
    fi
done

# 3. Idempotent installation: Only invoke DNF if there is actual work to be done
if [ ${#tools_to_install[@]} -gt 0 ]; then
    echo "→ Provisioning missing tools via DNF: ${tools_to_install[*]}..."
    sudo dnf install -y "${tools_to_install[@]}"
    echo "☑ Native tools successfully deployed"
else
    echo "☑ All native utilities are fully accounted for"
fi

echo -e '\n\n======================================== Installing VS Code ======================================\n'

# 1. Idempotent guard: Check if the 'code' binary is already visible in the system PATH
if command -v code >/dev/null 2>&1; then
    echo "☑ VS Code is already installed, skipping configuration and deployment"
else
    echo "→ VS Code not found. Initiating repository registration..."

    # Import the Microsoft cryptographic signing key safely into the system vault
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

    # Generate the repository definition file cleanly using a single EOF heredoc block
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

echo -e '\n\n=================================== Installing Node.js via NVM ===================================\n'

# 1. Define the localized NVM workspace
export NVM_DIR="$HOME/.nvm"

# 2. Idempotent Guard: Check if the directory structure already exists
if [ -d "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
    echo "☑ NVM architecture detected in home directory, skipping installation"

    # Temporarily source it into the script environment so we can use it downstream
    \. "$NVM_DIR/nvm.sh"
else
    echo "→ NVM not found. Fetching official installation binary..."

    # Download and execute the installer script directly into bash safely
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

    # Immediately initialize the newly installed environment for this active script pass
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    echo "→ Provisioning Node.js Long Term Support (LTS) release..."
    nvm install --lts
    echo "☑ Node.js LTS has been successfully registered to NVM"
fi

echo -e '\n\n================================ Installing Bun via Shell Engine =================================\n'

# 1. Define the local execution path for the Bun binary folder
export BUN_INSTALL="$HOME/.bun"

# 2. Idempotent Guard: Check if the raw executable file physically exists on disk
if [ -x "$BUN_INSTALL/bin/bun" ]; then
    echo "☑ Bun execution engine detected in user space, skipping network fetch"
    export PATH="$BUN_INSTALL/bin:$PATH"
else
    echo "→ Bun binary missing. Fetching official localized environment..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="$BUN_INSTALL/bin:$PATH"
    echo "☑ Bun utility successfully deployed to local workspace"
fi

# 3. Permanent Shell Injection: Ensure Bun revs up on every new Konsole tab
if grep -q "BUN_INSTALL" "$HOME/.bashrc"; then
    echo "☑ Bun environment paths are already wired into ~/.bashrc"
else
    echo "→ Injecting permanent Bun paths into ~/.bashrc..."
    echo -e '\n# Bun Environment Configuration' >> "$HOME/.bashrc"
    echo 'export BUN_INSTALL="$HOME/.bun"' >> "$HOME/.bashrc"
    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> "$HOME/.bashrc"
    echo "☑ Permanent shell configuration completed."
fi

# Install falkon

echo -e '\n\n======================================== Installing falkon =======================================\n'
if command -v falkon >/dev/null 2>&1; then
    echo '☑ falkon is already installed, skipping'
else
    sudo dnf install -y falkon
fi

#Check for versions

echo -e '\n\n==================================== System Verification Deck ====================================\n'

# 1. Hot-load the runtime environments into the script's active subshell context
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$HOME/.bun/bin:$PATH"

# 2. Define our target manifest map for clean tabular processing
# Format: "Binary_Name:Friendly_Label"
manifest=(
    "git:Git Version"
    "curl:Curl Version"
    "unzip:Unzip Version"
    "code:VS Code Version"
    "node:Node.js Version"
    "bun:Bun Engine Version"
    "falkon:Falkon Browser"
)

echo "--------------------------------------------------------------------------------"
# 3. Dynamic verification loop
for item in "${manifest[@]}"; do
    binary="${item%%:*}"
    label="${item#*:}"

    if command -v "$binary" >/dev/null 2>&1; then
        # Capture the version string, extracting just the first core line cleanly
        version_info=$("$binary" --version 2>&1 | head -n 1 || "$binary" -v 2>&1 | head -n 1)
        printf "  %-22s ⇒  \e[32m%s\e[0m\n" "$label" "$version_info"
    else
        printf "  %-22s ⇒  \e[31m⚠ Not Found\e[0m\n" "$label"
    fi
    echo "--------------------------------------------------------------------------------"
done

echo -e '\n\n=================================================|================================================\n'

# 🛈 - symbol when i need it
