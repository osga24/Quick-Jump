# 🚀 QuickJump
QuickJump is a beautiful, practical command-line tool that allows you to quickly jump to frequently used directories using custom hotkeys. Say goodbye to lengthy `cd` commands and boost your productivity!

![QuickJump Demo](screenshots/demo.gif)

- ✈️ [中文文檔請點擊這裡](README-ZH.md)

## ✨ Features

- 📁 Instantly jump to any directory with simple hotkeys
- 🏷️ Create custom hotkeys for your most frequently visited directories
- 🎨 Beautiful colorful interface with emoji decorations
- 🔄 Command and hotkey auto-completion
- 💾 Configuration files in JSON format for easy management and backup
- 🧹 Simple installation and uninstallation process
- 🍕 Good pizza has no pineapple on it!

## 📋 Requirements

- Bash or Zsh shell
- jq tool (for JSON processing)

## 🔧 Installation

### Automatic Installation

```bash
# Download the installer
git clone https://github.com/osga24/Quick-Jump.git

# Change to installation directory
cd Quick-Jump/

# Make it executable
chmod +x install.sh

# Run the installer
./install.sh
```

The installation script will automatically:
1. Check and install required dependencies
2. Create necessary configuration directories and files
3. Set up shell integration
4. Configure command auto-completion

### Manual Installation

If you prefer manual installation, follow these steps:

1. Make sure `jq` is installed:
   ```bash
   # macOS
   brew install jq
   
   # Debian/Ubuntu
   sudo apt install jq
   
   # RHEL/CentOS
   sudo yum install jq
   ```

2. Create configuration directory:
   ```bash
   mkdir -p ~/.config/quickjump
   ```

3. Download script files:
   ```bash
   curl -o ~/.config/quickjump/quickjump.sh https://raw.githubusercontent.com/osga24/Quick-Jump/main/quickjump.sh
   curl -o ~/.config/quickjump/quickjump-function.sh https://raw.githubusercontent.com/osga24/Quick-Jump/main/quickjump-function.sh
   chmod +x ~/.config/quickjump/quickjump.sh
   ```

4. Add to your shell configuration:
   ```bash
   echo '# QuickJump - Fast Directory Navigation Tool' >> ~/.zshrc  # or ~/.bashrc
   echo 'source ~/.config/quickjump/quickjump-function.sh' >> ~/.zshrc  # or ~/.bashrc
   ```

5. Reload configuration:
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

## 📖 Usage

### Basic Commands

```bash
# Add current directory as a hotkey
qj add work

# Add a specific directory as a hotkey
qj add docs ~/Documents

# Jump to a directory using its hotkey
qj work

# List all hotkeys
qj list

# Remove a hotkey
qj remove work

# Display help information
qj help
```

### Tips and Tricks

- Set intuitive hotkeys for your most frequently used directories
- Use tab completion to quickly select existing hotkeys
- If a directory no longer exists, QuickJump will prompt you to remove the hotkey

## 🗑️ Uninstallation

To uninstall QuickJump, simply run the provided uninstallation script:

```bash
# Get the uninstaller
git clone https://github.com/osga24/Quick-Jump.git
cd Quick-Jump/

# Make it executable
chmod +x uninstall.sh

# Run the uninstaller
./uninstall.sh
```

The uninstallation script provides options to backup your configuration and cleans up all related files and settings.

## 🤝 Contributing

Issues and Pull Requests are welcome to improve QuickJump! Whether it's fixing bugs, adding new features, or improving documentation, we appreciate all contributions.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

- Oscar - [GitHub](https://github.com/osga24)

For any questions or suggestions, feel free to open an issue or contact us. Happy jumping!
