## 🚀 QuickJump 快速目錄跳轉工具

QuickJump 是一個美觀、實用的命令行工具，讓您能夠使用自定義快捷鍵快速跳轉到常用目錄。告別冗長的 `cd` 命令，提高您的工作效率！

![QuickJump 演示](screenshots/demo.gif)

- ✈️ [英文文檔請點擊這裡](README.md)

### ✨ 特點

- 📁 使用簡單的快捷鍵瞬間跳轉到任何目錄
- 🏷️ 為您最常用的目錄創建自定義快捷鍵
- 🎨 精美的彩色界面和表情符號裝飾
- 🔄 命令和快捷鍵自動補全
- 💾 配置文件使用 JSON 格式，便於管理和備份
- 🧹 簡單的安裝和卸載流程
- 🍕 好吃的披薩上面沒有鳳梨！

### 📋 系統要求

- Bash 或 Zsh shell
- jq 工具 (用於處理 JSON)

### 🔧 安裝

#### 自動安裝

```bash
# 下載安裝腳本
git clone https://github.com/osga24/Quick-Jump.git

# 進入安裝目錄
cd Quick-Jump/

# 賦予執行權限
chmod +x install.sh

# 運行安裝腳本
./install.sh
```

安裝腳本會自動：
1. 檢查並安裝所需依賴
2. 創建必要的配置目錄和文件
3. 設置 shell 集成
4. 配置命令自動補全

#### 手動安裝

如果您偏好手動安裝，請按照以下步驟操作：

1. 確保已安裝 `jq`：
   ```bash
   # macOS
   brew install jq
   
   # Debian/Ubuntu
   sudo apt install jq
   
   # RHEL/CentOS
   sudo yum install jq
   ```

2. 創建配置目錄：
   ```bash
   mkdir -p ~/.config/quickjump
   ```

3. 下載腳本文件：
   ```bash
   curl -o ~/.config/quickjump/quickjump.sh https://raw.githubusercontent.com/osga24/quickjump/main/quickjump.sh
   curl -o ~/.config/quickjump/quickjump-function.sh https://raw.githubusercontent.com/osga24/quickjump/main/quickjump-function.sh
   chmod +x ~/.config/quickjump/quickjump.sh
   ```

4. 添加到您的 shell 配置：
   ```bash
   echo '# QuickJump - 快速目錄跳轉工具' >> ~/.zshrc  # 或 ~/.bashrc
   echo 'source ~/.config/quickjump/quickjump-function.sh' >> ~/.zshrc  # 或 ~/.bashrc
   ```

5. 重新加載配置：
   ```bash
   source ~/.zshrc  # 或 ~/.bashrc
   ```

### 📖 使用方法

#### 基本命令

```bash
# 將當前目錄添加為快捷鍵
qj add work

# 將特定目錄添加為快捷鍵
qj add docs ~/Documents

# 跳轉到快捷鍵對應的目錄
qj work

# 列出所有快捷鍵
qj list

# 刪除快捷鍵
qj remove work

# 顯示幫助信息
qj help
```

#### 提示和技巧

- 對於您最常用的目錄設置直觀的快捷鍵
- 使用標籤補全功能快速選擇現有的快捷鍵
- 如果目錄不再存在，QuickJump 會提示您是否要刪除該快捷鍵

### 🗑️ 卸載

如果您想卸載 QuickJump，只需運行提供的卸載腳本：

```bash
# 下載卸載腳本
curl -o uninstall.sh https://raw.githubusercontent.com/osga24/quickjump/main/uninstall.sh

# 賦予執行權限
chmod +x uninstall.sh

# 運行卸載腳本
./uninstall.sh
```

卸載腳本會提供配置備份選項，並清理所有相關文件和配置。

### 🤝 貢獻

歡迎提交 Issues 和 Pull Requests 來改進 QuickJump！無論是修復錯誤、添加新功能，還是改進文檔，我們都非常感謝您的貢獻。

### 📜 許可證

此項目採用 MIT 許可證 - 詳情請參閱 [LICENSE](LICENSE) 文件。

---

## 👨‍💻 Author | 作者

- OsGa - [GitHub](https://github.com/osga24)

For any questions or suggestions, feel free to open an issue or contact us. Happy jumping!

如有任何問題或建議，請隨時提出 Issue 或聯繫我們。祝您使用愉快！
