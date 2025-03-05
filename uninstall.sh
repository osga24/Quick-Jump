#!/bin/bash

# ===================================================
# 🧹 QuickJump Uninstaller
# Fast directory navigation tool uninstallation script
# ===================================================

# Colors and symbols
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # Reset color

# Emojis
BROOM="🧹"
CHECK="✅"
WARNING="⚠️"
ERROR="❌"
FOLDER="📁"
GEAR="⚙️"
TRASH="🗑️"
SAD="😢"
WAVE="👋"

# Output formatted messages
print_message() {
    emoji=$1
    color=$2
    message=$3
    echo -e "${color}${emoji} ${message}${NC}"
}

print_header() {
    echo -e "${CYAN}${BOLD}"
    echo "════════════════════════════════════════════════"
    echo "  ${BROOM} QuickJump Uninstaller ${BROOM}"
    echo "════════════════════════════════════════════════"
    echo -e "${NC}"
    echo -e "${YELLOW}This script will remove QuickJump and all its configurations${NC}\n"
}

# Ask user if they want to backup configuration
ask_for_backup() {
    # Check both possible configuration file locations
    CONFIG_FILE1="$HOME/.config/quickjump/paths.json"
    CONFIG_FILE2="$HOME/.config/quick-jump/paths.json"

    if [ -f "$CONFIG_FILE1" ]; then
        CONFIG_FILE="$CONFIG_FILE1"
    elif [ -f "$CONFIG_FILE2" ]; then
        CONFIG_FILE="$CONFIG_FILE2"
    else
        print_message "$WARNING" "$YELLOW" "No configuration file found"
        return
    fi

    echo -e "${YELLOW}${BOLD}Would you like to backup your hotkey settings before uninstalling?${NC}"
    echo -n "Backup hotkey configuration? (y/n): "
    read -r answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        BACKUP_FILE="$HOME/quickjump-backup-$(date +%Y%m%d-%H%M%S).json"
        cp "$CONFIG_FILE" "$BACKUP_FILE"
        print_message "$CHECK" "$GREEN" "Hotkey configuration backed up to: $BACKUP_FILE"
    else
        print_message "$WARNING" "$YELLOW" "No backup will be made, all hotkey settings will be deleted"
    fi
}

# Ask user to confirm uninstallation
confirm_uninstall() {
    echo -e "\n${RED}${BOLD}Warning: This will completely remove QuickJump and its configurations${NC}"
    echo -n "Confirm uninstallation of QuickJump? (y/n): "
    read -r answer

    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        print_message "$WAVE" "$BLUE" "Uninstallation cancelled, thank you for continuing to use QuickJump"
        exit 0
    fi
}

# Remove configuration files and directories
remove_config_files() {
    echo -e "\n${BOLD}${BLUE}[Step 1] Removing Configuration Files and Directories${NC}"

    # Check both possible configuration directories
    CONFIG_DIR1="$HOME/.config/quickjump"
    CONFIG_DIR2="$HOME/.config/quick-jump"

    if [ -d "$CONFIG_DIR1" ]; then
        rm -rf "$CONFIG_DIR1"
        print_message "$TRASH" "$GREEN" "Removed configuration directory: $CONFIG_DIR1"
    fi

    if [ -d "$CONFIG_DIR2" ]; then
        rm -rf "$CONFIG_DIR2"
        print_message "$TRASH" "$GREEN" "Removed configuration directory: $CONFIG_DIR2"
    fi

    if [ ! -d "$CONFIG_DIR1" ] && [ ! -d "$CONFIG_DIR2" ]; then
        print_message "$WARNING" "$YELLOW" "No configuration directories found"
    fi
}

# Remove from shell configuration
remove_from_shell_config() {
    echo -e "\n${BOLD}${BLUE}[Step 2] Removing from Shell Configuration${NC}"

    # Detect shell type
    SHELL_CONFIGS=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.zprofile")
    FOUND=0

    for config in "${SHELL_CONFIGS[@]}"; do
        if [ -f "$config" ]; then
            # Check for various possible configurations
            if grep -q "source.*quick.jump.*function.sh" "$config" || \
               grep -q "source.*quickjump.*function.sh" "$config" || \
               grep -q "source.*qj-function.sh" "$config"; then

                # Create temporary file
                TEMP_FILE=$(mktemp)

                # Filter out QuickJump related lines
                grep -v "source.*quick.jump.*function.sh" "$config" > "$TEMP_FILE"
                cat "$TEMP_FILE" > "$config"

                grep -v "source.*quickjump.*function.sh" "$config" > "$TEMP_FILE"
                cat "$TEMP_FILE" > "$config"

                grep -v "source.*qj-function.sh" "$config" > "$TEMP_FILE"
                cat "$TEMP_FILE" > "$config"

                grep -v "# QuickJump -" "$config" > "$TEMP_FILE"
                cat "$TEMP_FILE" > "$config"

                grep -v "# Quick Jump -" "$config" > "$TEMP_FILE"
                cat "$TEMP_FILE" > "$config"

                rm "$TEMP_FILE"

                print_message "$CHECK" "$GREEN" "Removed QuickJump configuration from $config"
                FOUND=1
            fi
        fi
    done

    if [ $FOUND -eq 0 ]; then
        print_message "$WARNING" "$YELLOW" "No QuickJump configuration found in any shell configuration files"
    fi
}

# Unload function from current session
unload_function() {
    echo -e "\n${BOLD}${BLUE}[Step 3] Unloading Function from Current Session${NC}"

    # Check if function exists
    if type qj > /dev/null 2>&1; then
        # Try to unload function
        unset -f qj 2>/dev/null
        print_message "$CHECK" "$GREEN" "Unloaded qj function from current session"
    else
        print_message "$WARNING" "$YELLOW" "qj function not found in current session"
    fi
}

# Complete uninstallation
finish_uninstall() {
    echo -e "\n${BOLD}${GREEN}[Step 4] Completing Uninstallation${NC}"

    echo -e "\n${GREEN}${BOLD}${CHECK} QuickJump has been successfully uninstalled!${NC}\n"

    print_message "$GEAR" "$YELLOW" "To make changes fully effective, please restart your terminal or run:"
    echo -e "    ${CYAN}exec zsh${NC} or ${CYAN}exec bash${NC}"

    echo -e "\n${PURPLE}${BOLD}${SAD} Thank you for having used QuickJump!${NC}"
    print_message "$WAVE" "$BLUE" "If you have any feedback, please submit an issue on GitHub."
    echo -e "\n${YELLOW}Goodbye! ${WAVE}${NC}\n"
}

# Execute main uninstallation steps
print_header
ask_for_backup
confirm_uninstall
remove_config_files
remove_from_shell_config
unload_function
finish_uninstall
