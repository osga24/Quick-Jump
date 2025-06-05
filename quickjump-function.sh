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
			echo "$target_dir"
		fi
	fi
}

# Auto-completion setup
_qj_completions() {
	local cur prev
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD - 1]}"

	if [ "$COMP_CWORD" -eq 1 ]; then
		# Main command auto-completion
		local commands="add list remove help"
		local hotkeys=$(jq -r 'keys[]' "$HOME/.config/quickjump/paths.json" 2>/dev/null)
		COMPREPLY=($(compgen -W "${commands} ${hotkeys}" -- ${cur}))
	elif [ "$COMP_CWORD" -gt 1 ] && [ "$prev" = "add" ]; then
		# Path auto-completion after 'add' command
		COMPREPLY=($(compgen -d -- ${cur}))
	elif [ "$COMP_CWORD" -gt 1 ] && [ "$prev" = "remove" ]; then
		# Hotkey auto-completion after 'remove' command
		local hotkeys=$(jq -r 'keys[]' "$HOME/.config/quickjump/paths.json" 2>/dev/null)
		COMPREPLY=($(compgen -W "${hotkeys}" -- ${cur}))
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
