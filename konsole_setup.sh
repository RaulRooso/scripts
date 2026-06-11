#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Universal Error Trapping Mechanism
trap 'echo "🗵 Konsole Setup failed at line $LINENO"; exit 1' ERR

echo -e '\n=============================================================================================================='
echo -e '                                      Deploying Konsole Master Architecture                                    '
echo -e '=============================================================================================================='

# Target definitions
TARGET_PROFILE_NAME="Mainline"
PROFILE_DIR="$HOME/.local/share/konsole"
COLORSCHEME_FILE="$PROFILE_DIR/${TARGET_PROFILE_NAME}.colorscheme"
PROFILE_FILE="$PROFILE_DIR/${TARGET_PROFILE_NAME}.profile"

# Ensure the directory exists like a good sysadmin
mkdir -p "$PROFILE_DIR"

# --- THE SURGICAL ENGINE ---
# Arguments: 1=File, 2=Group, 3=Key, 4=DesiredValue, 5=FriendlyLabel
set_konsole_setting() {
    local file="$1"
    local group="$2"
    local key="$3"
    local value="$4"
    local label="$5"

    # Read the current live state
    local current_val
    current_val=$(kreadconfig6 --file "$file" --group "$group" --key "$key")

    # Sync only if things differ
    if [ "$current_val" != "$value" ]; then
        echo "→ $label differs or is missing. Syncing state..."
        kwriteconfig6 --file "$file" --group "$group" --key "$key" "$value"
        echo "  ☑ $label successfully updated to: $value"
    else
        echo "  ☑ $label is already verified, skipping."
    fi
}


# ==============================================================================================================
# 1. Minting the Color Palette (Mainline.colorscheme) - Warm Gray Background / Organic Matte Text
# ==============================================================================================================
echo -e "\nEvaluating Color Palette Geometry..."

set_konsole_setting "$COLORSCHEME_FILE" "General" "Description" "$TARGET_PROFILE_NAME" "Color Schema Name"
set_konsole_setting "$COLORSCHEME_FILE" "General" "Opacity" "0.9" "Window Transparency/Opacity"
set_konsole_setting "$COLORSCHEME_FILE" "General" "Blur" "false" "Background Blur State"

# Your comfortable, warm neutral slate gray background
set_konsole_setting "$COLORSCHEME_FILE" "Background" "Color" "30,30,30" "Standard Background Color"
set_konsole_setting "$COLORSCHEME_FILE" "BackgroundIntense" "Color" "45,45,45" "Intense Background Color"

# Softened, matte industrial silver main text to completely eliminate eye fatigue
set_konsole_setting "$COLORSCHEME_FILE" "Foreground" "Color" "179,179,179" "Softer Matte Main Text (#b3b3b3)"
set_konsole_setting "$COLORSCHEME_FILE" "ForegroundIntense" "Color" "220,220,220" "Velvet White Highlight Text"

# ==============================================================================================================
# 1b. Injecting the Organic Matte ANSI Palette Matrix (Standard Slots - Deep Anchor Base Inks)
# ==============================================================================================================
echo -e "\nEngineering Base ANSI Spectrum..."

set_konsole_setting "$COLORSCHEME_FILE" "Color0" "Color" "40,45,50"     "ANSI 0 - Base Obsidian Slate"
set_konsole_setting "$COLORSCHEME_FILE" "Color1" "Color" "135,40,40"    "ANSI 1 - Muted Deep Madder Red"
set_konsole_setting "$COLORSCHEME_FILE" "Color2" "Color" "0,95,65"      "ANSI 2 - Deep Forest Ink Green"
set_konsole_setting "$COLORSCHEME_FILE" "Color3" "Color" "190,140,60"    "ANSI 3 - Matte Amber Gold Base"
set_konsole_setting "$COLORSCHEME_FILE" "Color4" "Color" "33,104,130"    "ANSI 4 - Deep Steel Blue (#216882)"
set_konsole_setting "$COLORSCHEME_FILE" "Color5" "Color" "95,0,95"      "ANSI 5 - Dark Byzantine Plum Purple"
set_konsole_setting "$COLORSCHEME_FILE" "Color6" "Color" "29,99,94"      "ANSI 6 - Dark Pine Teal (#1d635e)"
set_konsole_setting "$COLORSCHEME_FILE" "Color7" "Color" "170,170,170"  "ANSI 7 - Matte Industrial Silver"

# ==============================================================================================================
# 1c. Injecting the High-Intensity Matte Highlights (Intense Slots)
# ==============================================================================================================
echo -e "\nEngineering High-Intensity ANSI Highlights..."

set_konsole_setting "$COLORSCHEME_FILE" "Color0Intense" "Color" "64,74,80"    "ANSI 8  - Velvet Charcoal Slate"
set_konsole_setting "$COLORSCHEME_FILE" "Color1Intense" "Color" "180,55,50"   "ANSI 9  - Saturated Brick Crimson"
set_konsole_setting "$COLORSCHEME_FILE" "Color2Intense" "Color" "0,112,84"    "ANSI 10 - Rich Emerald Pine Green"
set_konsole_setting "$COLORSCHEME_FILE" "Color3Intense" "Color" "225,165,65"  "ANSI 11 - Snippet Honey Amber Gold (Yellow)"
set_konsole_setting "$COLORSCHEME_FILE" "Color4Intense" "Color" "50,135,165"  "ANSI 12 - High-Contrast Steel Turquoise (Blue)"
set_konsole_setting "$COLORSCHEME_FILE" "Color5Intense" "Color" "115,15,95"   "ANSI 13 - Imperial Velvet Purple"
set_konsole_setting "$COLORSCHEME_FILE" "Color6Intense" "Color" "45,135,128"  "ANSI 14 - Bold Deep Alpine Teal"
set_konsole_setting "$COLORSCHEME_FILE" "Color7Intense" "Color" "235,235,235"  "ANSI 15 - Soft Vintage Off-White"

# ==============================================================================================================
# 2. Constructing Profile Geometry (Mainline.profile)
# ==============================================================================================================
echo -e "\nEvaluating Profile Configurations..."

set_konsole_setting "$PROFILE_FILE" "General" "Name" "$TARGET_PROFILE_NAME" "Profile View Name"
set_konsole_setting "$PROFILE_FILE" "General" "Parent" "FALLBACK/" "Profile Base Parent"
set_konsole_setting "$PROFILE_FILE" "Appearance" "ColorScheme" "$TARGET_PROFILE_NAME" "Profile Color Assignment"

# Retaining your customized cursor mechanics
set_konsole_setting "$PROFILE_FILE" "Cursor Options" "CursorShape" "1" "Terminal Cursor Geometry (Block)"
set_konsole_setting "$PROFILE_FILE" "Cursor Options" "UseCustomCursorColor" "true" "Enable Custom Cursor Color Overrides"
set_konsole_setting "$PROFILE_FILE" "Cursor Options" "CustomCursorColor" "255,158,100" "Custom Sunset Orange Cursor Color"
set_konsole_setting "$PROFILE_FILE" "Cursor Options" "CustomCursorTextColor" "30,30,30" "Dark Text Overlay Underneath Cursor Block"

set_konsole_setting "$PROFILE_FILE" "Terminal Features" "BlinkingCursorEnabled" "true" "Terminal Cursor Animation Pulse"

# ==============================================================================================================
# 3. Routing System Defaults (konsolerc)
# ==============================================================================================================
echo -e "\nEvaluating System Routing Handlers..."

set_konsole_setting "$PROFILE_FILE" "General" "TerminalMargin" "0" "Terminal Padding Geometry"
set_konsole_setting "konsolerc" "Desktop Entry" "DefaultProfile" "${TARGET_PROFILE_NAME}.profile" "Global System Default Profile"
set_konsole_setting "konsolerc" "Favorite Profiles" "Favorites" "${TARGET_PROFILE_NAME}.profile" "System Favorite Docking Matrix"

echo -e "\n🛈 Konsole dynamic customization engine run complete.\n"



#for testing the text color look
#echo -e "\n  ANSI |   Standard (0-7)   |   Intense (8-15)\n  -----+--------------------+--------------------" && for i in {0..7}; do j=$((i+8)); printf "   %1d   |  \e[3%dm██████████████\e[0m  |  \e[9%dm██████████████\e[0m\n" "$i" "$i" "$i"; done && echo
