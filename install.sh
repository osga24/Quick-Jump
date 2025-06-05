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
			grep -v "source.*quick-jump" "$config" >"$TEMP_FILE"
			cat "$TEMP_FILE" >"$config"
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
	if ! command -v jq &>/dev/null; then
		print_message "$WARNING" "$YELLOW" "jq (JSON processor) is not installed"
		missing_deps=1
	else
		print_message "$CHECK" "$GREEN" "jq is installed"
	fi

	# If there are missing dependencies, try to install them
	if [ $missing_deps -eq 1 ]; then
		print_message "$GEAR" "$BLUE" "Attempting to install missing dependencies..."

		if command -v brew &>/dev/null; then
			print_message "$GEAR" "$BLUE" "Installing with Homebrew..."
			brew install jq
		elif command -v apt &>/dev/null; then
			print_message "$GEAR" "$BLUE" "Installing with apt..."
			sudo apt update && sudo apt install -y jq
		elif command -v yum &>/dev/null; then
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
		if ! command -v jq &>/dev/null; then
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
		echo '{}' >"$CONFIG_FILE"
		print_message "$CHECK" "$GREEN" "Created configuration file: $CONFIG_FILE"
	else
		print_message "$CHECK" "$YELLOW" "Configuration file already exists: $CONFIG_FILE"
	fi
}

# Copy required scripts
copy_required_scripts() {
	print_step "3" "Installing required scripts"

	# Get installation directory
	INSTALL_DIR="$(dirname "${BASH_SOURCE[0]}")"

	# Check required files
	MAIN_SCRIPT="$INSTALL_DIR/main.sh"
	FUNCTION_SCRIPT="$INSTALL_DIR/quickjump-function.sh"

	if [ ! -f "$MAIN_SCRIPT" ]; then
		print_message "$ERROR" "$RED" "main.sh not found in installation directory: $INSTALL_DIR"
		print_message "$ERROR" "$RED" "Please ensure main.sh is in the same directory as install.sh"
		exit 1
	fi

	if [ ! -f "$FUNCTION_SCRIPT" ]; then
		print_message "$ERROR" "$RED" "quickjump-function.sh not found in installation directory: $INSTALL_DIR"
		print_message "$ERROR" "$RED" "Please ensure quickjump-function.sh is in the same directory as install.sh"
		exit 1
	fi

	# Copy main script
	SCRIPT_FILE="$CONFIG_DIR/quickjump.sh"
	cp "$MAIN_SCRIPT" "$SCRIPT_FILE"
	chmod +x "$SCRIPT_FILE"
	print_message "$MAGIC" "$GREEN" "Copied main script: $MAIN_SCRIPT -> $SCRIPT_FILE"

	# Copy function script
	FUNCTION_FILE="$CONFIG_DIR/quickjump-function.sh"
	cp "$FUNCTION_SCRIPT" "$FUNCTION_FILE"
	print_message "$MAGIC" "$GREEN" "Copied function script: $FUNCTION_SCRIPT -> $FUNCTION_FILE"
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
		echo "" >>"$SHELL_CONFIG"
		echo "# QuickJump - Fast Directory Navigation Tool" >>"$SHELL_CONFIG"
		echo "source $HOME/.config/quickjump/quickjump-function.sh" >>"$SHELL_CONFIG"
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
copy_required_scripts
update_shell_config
finish_installation
