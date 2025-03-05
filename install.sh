#!/bin/bash

# ===================================================
# 🚀 QuickJump Installer
# Fast directory navigation tool installation script
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
ROCKET="🚀"
CHECK="✅"
WARNING="⚠️"
ERROR="❌"
FOLDER="📁"
GEAR="⚙️"
LINK="🔗"
STAR="⭐"
MAGIC="✨"
TRASH="🗑️"

# Output formatted messages
print_message() {
    emoji=$1
    color=$2
    message=$3
    echo -e "${color}${emoji} ${message}${NC}"
}

print_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "════════════════════════════════════════════════"
    echo "  ${ROCKET} QuickJump - Fast Directory Navigation ${ROCKET}"
    echo "════════════════════════════════════════════════"
    echo -e "${NC}"
    echo -e "${BLUE}Jump to any directory instantly with custom hotkeys${NC}"
    echo -e "${YELLOW}Author: Your Name${NC}\n"
}

print_step() {
    step_num=$1
    step_name=$2
    echo -e "\n${PURPLE}${BOLD}[Step $step_num] $step_name ${NC}"
}

# Check and clean old versions
clean_old_version() {
    print_step "0" "Cleaning old versions"

    # Check and remove old local bin script
    if [ -f "$HOME/.local/bin/quick-jump.sh" ]; then
        rm -f "$HOME/.local/bin/quick-jump.sh"
        print_message "$TRASH" "$GREEN" "Removed old script: $HOME/.local/bin/quick-jump.sh"
    fi

    # Check and remove old config directory
    if [ -d "$HOME/.config/quick-jump" ]; then
        rm -rf "$HOME/.config/quick-jump"
        print_message "$TRASH" "$GREEN" "Removed old config directory: $HOME/.config/quick-jump"
    fi

    # Check shell config files for old configurations
    SHELL_CONFIGS=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.zprofile")
    for config in "${SHELL_CONFIGS[@]}"; do
        if [ -f "$config" ] && grep -q "source.*quick-jump" "$config"; then
            # Create temporary file
            TEMP_FILE=$(mktemp)
            # Remove lines containing quick-jump
            grep -v "source.*quick-jump" "$config" > "$TEMP_FILE"
            cat "$TEMP_FILE" > "$config"
            rm "$TEMP_FILE"
            print_message "$CHECK" "$GREEN" "Removed old configuration from $config"
        fi
    done

    # Try to unload old version function
    unset -f qj 2>/dev/null
    print_message "$CHECK" "$GREEN" "Completed old version cleanup"
}

# Check dependencies
check_dependencies() {
    print_step "1" "Checking required dependencies"

    missing_deps=0

    # Check for jq
    if ! command -v jq &> /dev/null; then
        print_message "$WARNING" "$YELLOW" "jq (JSON processor) is not installed"
        missing_deps=1
    else
        print_message "$CHECK" "$GREEN" "jq is installed"
    fi

    # If there are missing dependencies, try to install them
    if [ $missing_deps -eq 1 ]; then
        print_message "$GEAR" "$BLUE" "Attempting to install missing dependencies..."

        if command -v brew &> /dev/null; then
            print_message "$GEAR" "$BLUE" "Installing with Homebrew..."
            brew install jq
        elif command -v apt &> /dev/null; then
            print_message "$GEAR" "$BLUE" "Installing with apt..."
            sudo apt update && sudo apt install -y jq
        elif command -v yum &> /dev/null; then
            print_message "$GEAR" "$BLUE" "Installing with yum..."
            sudo yum install -y jq
        else
            print_message "$ERROR" "$RED" "Unable to automatically install dependencies. Please install jq manually and try again."
            print_message "$LINK" "$BLUE" "macOS: brew install jq"
            print_message "$LINK" "$BLUE" "Debian/Ubuntu: sudo apt install jq"
            print_message "$LINK" "$BLUE" "CentOS/RHEL: sudo yum install jq"
            exit 1
        fi

        # Check again for jq
        if ! command -v jq &> /dev/null; then
            print_message "$ERROR" "$RED" "Dependency installation failed. Please install jq manually and try again."
            exit 1
        else
            print_message "$CHECK" "$GREEN" "All dependencies have been successfully installed!"
        fi
    else
        print_message "$CHECK" "$GREEN" "All dependency checks passed!"
    fi
}

# Set up configuration directories and files
setup_directories() {
    print_step "2" "Setting up configuration directory"

    CONFIG_DIR="$HOME/.config/quickjump"
    CONFIG_FILE="$CONFIG_DIR/paths.json"

    # Create configuration directory
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        print_message "$FOLDER" "$GREEN" "Created configuration directory: $CONFIG_DIR"
    else
        print_message "$FOLDER" "$YELLOW" "Configuration directory already exists: $CONFIG_DIR"
    fi

    # Create JSON configuration file
    if [ ! -f "$CONFIG_FILE" ]; then
        echo '{}' > "$CONFIG_FILE"
        print_message "$CHECK" "$GREEN" "Created configuration file: $CONFIG_FILE"
    else
        print_message "$CHECK" "$YELLOW" "Configuration file already exists: $CONFIG_FILE"
    fi
}

# Create main script
create_main_script() {
    print_step "3" "Creating main script"

    SCRIPT_FILE="$CONFIG_DIR/quickjump.sh"

    cat > "$SCRIPT_FILE" << 'EOF'
#!/bin/bash

# ==============================================
# 🚀 QuickJump - Fast Directory Navigation Tool
# ==============================================

# Colors and symbols
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # Reset color

# Configuration file location
CONFIG_FILE="$HOME/.config/quickjump/paths.json"

# Output formatted messages
print_message() {
    emoji=$1
    color=$2
    message=$3
    echo -e "${color}${emoji} ${message}${NC}"
}

# Check if configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo '{}' > "$CONFIG_FILE"
    print_message "✨" "$GREEN" "Created new configuration file"
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    print_message "❌" "$RED" "jq tool not found, please install jq first"
    print_message "🔗" "$BLUE" "macOS: brew install jq"
    print_message "🔗" "$BLUE" "Ubuntu/Debian: sudo apt install jq"
    exit 1
fi

# Add a hotkey
add_hotkey() {
    local hotkey="$1"
    local path="$2"

    # If no path is provided, use current directory
    if [ -z "$path" ]; then
        path="$(pwd)"
    fi

    # Ensure the path exists
    if [ ! -d "$path" ]; then
        print_message "❌" "$RED" "Directory '$path' does not exist"
        return 1
    fi

    # Convert to absolute path
    if command -v realpath &> /dev/null; then
        path="$(realpath "$path")"
    else
        if [ -d "$path" ]; then
            path="$(cd "$path" && pwd)"
        fi
    fi

    # Check if the same hotkey already exists
    local exists=$(jq --arg hotkey "$hotkey" 'has($hotkey)' "$CONFIG_FILE")
    if [ "$exists" = "true" ]; then
        local old_path=$(jq -r --arg hotkey "$hotkey" '.[$hotkey]' "$CONFIG_FILE")
        print_message "⚠️" "$YELLOW" "Hotkey '$hotkey' already exists, pointing to: $old_path"
        echo -n "Overwrite? (y/n): "
        read -r answer
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            print_message "🛑" "$YELLOW" "Operation cancelled"
            return 0
        fi
    fi

    # Add the hotkey to the JSON file
    jq --arg hotkey "$hotkey" --arg path "$path" '. + {($hotkey): $path}' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
    mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    print_message "✅" "$GREEN" "Added hotkey '$hotkey' => '$path'"
}

# Jump to a directory
goto_hotkey() {
    local hotkey="$1"

    # Get the path from the JSON file
    local path="$(jq -r --arg hotkey "$hotkey" '.[$hotkey] // empty' "$CONFIG_FILE")"

    if [ -z "$path" ] || [ "$path" = "null" ]; then
        print_message "❌" "$RED" "Hotkey '$hotkey' not found"
        return 1
    fi

    if [ ! -d "$path" ]; then
        print_message "❌" "$RED" "Directory '$path' no longer exists"
        echo -n "Remove this invalid hotkey? (y/n): "
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            jq --arg hotkey "$hotkey" 'del(.[$hotkey])' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
            mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
            print_message "✅" "$GREEN" "Removed invalid hotkey '$hotkey'"
        fi
        return 1
    fi

    # Output the path to jump to (for the shell function to use)
    echo "$path"
}

# List all hotkeys
list_hotkeys() {
    echo -e "${CYAN}${BOLD}============================================${NC}"
    echo -e "${CYAN}${BOLD}  📁 QuickJump Hotkey List  ${NC}"
    echo -e "${CYAN}${BOLD}============================================${NC}"

    # Get the number of hotkeys
    local count=$(jq 'length' "$CONFIG_FILE")
    if [ "$count" -eq 0 ]; then
        print_message "ℹ️" "$YELLOW" "No hotkeys set up yet"
        print_message "💡" "$BLUE" "Use 'qj add <hotkey> [path]' to add your first hotkey"
        return 0
    fi

    print_message "📊" "$BLUE" "Total of $count hotkeys"
    echo ""

    # Format output - use printf for proper formatting instead of tabs
    printf "${BOLD}  %-15s %s${NC}\n" "Hotkey" "Directory Path"
    printf "${BOLD}  %-15s %s${NC}\n" "---------------" "--------------------"

    # Output hotkeys and paths in table format using printf for alignment
    jq -r 'to_entries | .[] | [.key, .value] | @tsv' "$CONFIG_FILE" | sort | while IFS=$'\t' read -r key path; do
        printf "${GREEN}  %-15s${NC} ${BLUE}%s${NC}\n" "$key" "$path"
    done

    echo -e "\n${CYAN}${BOLD}============================================${NC}"
}
# Remove a hotkey
remove_hotkey() {
    local hotkey="$1"

    # Check if the hotkey exists
    local exists="$(jq --arg hotkey "$hotkey" 'has($hotkey)' "$CONFIG_FILE")"

    if [ "$exists" = "false" ]; then
        print_message "❌" "$RED" "Hotkey '$hotkey' does not exist"
        return 1
    fi

    # Get the path that will be removed
    local path=$(jq -r --arg hotkey "$hotkey" '.[$hotkey]' "$CONFIG_FILE")

    # Confirm deletion
    print_message "⚠️" "$YELLOW" "About to delete hotkey: '$hotkey' => '$path'"
    echo -n "Are you sure? (y/n): "
    read -r answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        print_message "🛑" "$YELLOW" "Deletion cancelled"
        return 0
    fi

    # Remove the hotkey from the JSON file
    jq --arg hotkey "$hotkey" 'del(.[$hotkey])' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
    mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    print_message "✅" "$GREEN" "Removed hotkey '$hotkey'"
}

# Show usage help
show_help() {
    echo -e "${CYAN}${BOLD}============================================${NC}"
    echo -e "${CYAN}${BOLD}  🚀 QuickJump - Fast Directory Navigation  ${NC}"
    echo -e "${CYAN}${BOLD}============================================${NC}"
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  ${GREEN}qj add${NC} ${YELLOW}<hotkey>${NC} ${BLUE}[path]${NC}   - Add directory hotkey (defaults to current directory)"
    echo -e "  ${GREEN}qj${NC} ${YELLOW}<hotkey>${NC}              - Jump to directory"
    echo -e "  ${GREEN}qj list${NC}                - List all hotkeys"
    echo -e "  ${GREEN}qj remove${NC} ${YELLOW}<hotkey>${NC}       - Remove a hotkey"
    echo -e "  ${GREEN}qj help${NC}                - Show this help"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  ${GREEN}qj add${NC} ${YELLOW}work${NC}              - Add current directory as 'work' hotkey"
    echo -e "  ${GREEN}qj add${NC} ${YELLOW}docs${NC} ${BLUE}~/Documents${NC}  - Add ~/Documents as 'docs' hotkey"
    echo -e "  ${GREEN}qj${NC} ${YELLOW}work${NC}                 - Jump to the 'work' directory"
    echo -e "${CYAN}${BOLD}============================================${NC}"
}

# If called from the shell function (for actual directory jumping)
if [ "$1" = "--get-path" ]; then
    goto_hotkey "$2"
    exit
fi

# Process commands
case "$1" in
    "add")
        if [ -z "$2" ]; then
            print_message "❌" "$RED" "You must provide a hotkey name"
            show_help
            exit 1
        fi
        add_hotkey "$2" "$3"
        ;;
    "list")
        list_hotkeys
        ;;
    "remove")
        if [ -z "$2" ]; then
            print_message "❌" "$RED" "You must provide a hotkey name to remove"
            exit 1
        fi
        remove_hotkey "$2"
        ;;
    "help")
        show_help
        ;;
    *)
        if [ -z "$1" ]; then
            show_help
        else
            goto_hotkey "$1"
        fi
        ;;
esac
EOF

    # Set execute permissions
    chmod +x "$SCRIPT_FILE"
    print_message "$MAGIC" "$GREEN" "Created main script: $SCRIPT_FILE"

    # Create shell function file
    FUNCTION_FILE="$CONFIG_DIR/quickjump-function.sh"

    cat > "$FUNCTION_FILE" << 'EOF'
# QuickJump - Fast Directory Navigation Function

# Colors
GREEN='\033[0;32m'
NC='\033[0m' # Reset color

# qj command function
qj() {
    if [ "$1" = "add" ] || [ "$1" = "list" ] || [ "$1" = "remove" ] || [ "$1" = "help" ] || [ -z "$1" ]; then
        "$HOME/.config/quickjump/quickjump.sh" "$@"
    else
        local target_dir=$("$HOME/.config/quickjump/quickjump.sh" --get-path "$1")
        if [[ "$target_dir" == /* ]]; then
            cd "$target_dir"
            echo -e "${GREEN}🚀 Jumped to: $target_dir${NC}"
        else
            # Output error message
            echo "$target_dir"
        fi
    fi
}

# Auto-completion setup
_qj_completions() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [ "$COMP_CWORD" -eq 1 ]; then
        # Main command auto-completion
        local commands="add list remove help"
        local hotkeys=$(jq -r 'keys[]' "$HOME/.config/quickjump/paths.json" 2>/dev/null)
        COMPREPLY=( $(compgen -W "${commands} ${hotkeys}" -- ${cur}) )
    elif [ "$COMP_CWORD" -gt 1 ] && [ "$prev" = "add" ]; then
        # Path auto-completion after 'add' command
        COMPREPLY=( $(compgen -d -- ${cur}) )
    elif [ "$COMP_CWORD" -gt 1 ] && [ "$prev" = "remove" ]; then
        # Hotkey auto-completion after 'remove' command
        local hotkeys=$(jq -r 'keys[]' "$HOME/.config/quickjump/paths.json" 2>/dev/null)
        COMPREPLY=( $(compgen -W "${hotkeys}" -- ${cur}) )
    fi

    return 0
}

# Enable auto-completion
if [ -n "$BASH_VERSION" ]; then
    complete -F _qj_completions qj
elif [ -n "$ZSH_VERSION" ]; then
    # ZSH compatibility handling
    autoload -U +X compinit && compinit
    autoload -U +X bashcompinit && bashcompinit
    complete -F _qj_completions qj
fi

# Welcome message (commented out to avoid Powerlevel10k instant prompt issues)
# echo -e "${GREEN}🚀 QuickJump is ready!${NC} Use ${GREEN}qj help${NC} to see usage instructions"
EOF

    print_message "$MAGIC" "$GREEN" "Created function definition file: $FUNCTION_FILE"
}

# Update shell configuration
update_shell_config() {
    print_step "4" "Updating Shell Configuration"

    # Detect shell type
    SHELL_CONFIG=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_CONFIG="$HOME/.zshrc"
        SHELL_NAME="Zsh"
    elif [[ "$SHELL" == *"bash"* ]]; then
        SHELL_CONFIG="$HOME/.bashrc"
        SHELL_NAME="Bash"
    else
        print_message "$WARNING" "$YELLOW" "Unable to automatically detect your shell type"
        echo "Please manually add the following line to your shell configuration file:"
        echo "source $HOME/.config/quickjump/quickjump-function.sh"
        return 0
    fi

    print_message "$GEAR" "$BLUE" "Detected $SHELL_NAME shell"

    # Check if already configured
    if grep -q "source.*quickjump-function.sh" "$SHELL_CONFIG"; then
        print_message "$CHECK" "$GREEN" "QuickJump is already configured in your $SHELL_NAME configuration file"
    else
        # Add to shell configuration
        echo "" >> "$SHELL_CONFIG"
        echo "# QuickJump - Fast Directory Navigation Tool" >> "$SHELL_CONFIG"
        echo "source $HOME/.config/quickjump/quickjump-function.sh" >> "$SHELL_CONFIG"
        print_message "$CHECK" "$GREEN" "Added QuickJump to your $SHELL_NAME configuration file"
    fi
}

# Complete installation
finish_installation() {
    print_step "5" "Completing Installation"

    echo -e "\n${GREEN}${BOLD}${ROCKET} QuickJump installation successful! ${ROCKET}${NC}\n"

    print_message "$STAR" "$YELLOW" "To activate QuickJump immediately:"
    echo -e "    ${CYAN}source $HOME/.config/quickjump/quickjump-function.sh${NC}"

    print_message "$STAR" "$YELLOW" "Or restart your terminal for automatic activation"

    echo -e "\n${BLUE}${BOLD}Common commands:${NC}"
    echo -e "  ${GREEN}qj add work${NC}           - Add current directory as 'work' hotkey"
    echo -e "  ${GREEN}qj add docs ~/Documents${NC}  - Add specific directory as 'docs' hotkey"
    echo -e "  ${GREEN}qj work${NC}              - Jump to the 'work' directory"
    echo -e "  ${GREEN}qj list${NC}              - List all hotkeys"
    echo -e "  ${GREEN}qj remove work${NC}       - Remove the 'work' hotkey"
    echo -e "  ${GREEN}qj help${NC}              - Show help information"

    echo -e "\n${PURPLE}${BOLD}Thank you for using QuickJump! ${STAR}${NC}\n"
}

# Main program
print_header
clean_old_version
check_dependencies
setup_directories
create_main_script
update_shell_config
finish_installation
