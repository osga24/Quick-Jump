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
	echo '{}' >"$CONFIG_FILE"
	print_message "✨" "$GREEN" "Created new configuration file"
fi

# Check if jq is installed
if ! command -v jq &>/dev/null; then
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
	if command -v realpath &>/dev/null; then
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
	jq --arg hotkey "$hotkey" --arg path "$path" '. + {($hotkey): $path}' "$CONFIG_FILE" >"$CONFIG_FILE.tmp"
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
			jq --arg hotkey "$hotkey" 'del(.[$hotkey])' "$CONFIG_FILE" >"$CONFIG_FILE.tmp"
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
	jq --arg hotkey "$hotkey" 'del(.[$hotkey])' "$CONFIG_FILE" >"$CONFIG_FILE.tmp"
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
