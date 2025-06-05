# 🚀 DevEnv Installer

A **Ruby Command-Line Interface (CLI) tool** to automate and streamline your development environment setup. Easily install essential packages, manage dependencies, and enjoy a smooth onboarding experience on macOS and Linux.

---

## 📖 Overview

The **DevEnv Installer** helps you:

- Select and install individual packages or a predefined set of defaults.
- Automatically resolve dependencies.
- Get prompted for administrator privileges when needed.
- Receive a summary of which installations succeeded or failed.

---

## ✨ Features

- **Interactive CLI:** Easy-to-use menu for package selection.
- **Modular Design:** Add new packages and installation methods with minimal effort.
- **Dependency Resolution:** Installs dependencies in the correct order.
- **Homebrew Integration:** Uses Homebrew for macOS package management.
- **Curl & Gem Integration:** Supports script-based installs with `curl` and Ruby gems.
- **Sudo Prompting:** Securely requests your password if root access is needed.
- **Installation Summary:** Clear overview of completed and failed installs.

---

## ⚡ Prerequisites

Make sure you have the following before running the script:

| Requirement       | Notes                                                                                          |
|-------------------|------------------------------------------------------------------------------------------------|
| **Ruby**          | Required to run the script. Pre-installed on macOS; install via your package manager if missing. |
| **Git**           | Needed for some curl-based installations.                                                     |
| **Internet**      | Required to download packages/scripts.                                                        |
| **macOS/Linux**   | Compatible with both. For Linux, use your distro’s package manager to install Ruby if needed.  |

---

## 🛠️ Installation & Usage

### 1. **Download the Script**

Save the Ruby code as `install_devenv.rb` (or any `.rb` extension).

### 2. **Make the Script Executable**

```bash
chmod +x install_devenv.rb
```

### 3. **Run the Installer**

```bash
./install_devenv.rb
```

### 4. **Follow the Prompts**

- **Homebrew:** If not found, you'll be prompted to install it (recommended for macOS).
- **Menu:** Choose packages by entering their numbers (e.g. `1`, `1 3 5`, or `1,3,5`).
- **All Defaults:** Type `a` or `all` to install all default packages.
- **Quit:** Type `q`, `quit`, or `exit` to stop.

---

## 💡 Example Workflow

```
./install_devenv.rb

🚀 DevEnv Installer
==================

Welcome! This tool helps you install development packages quickly and easily.

🔍 Checking prerequisites...
⚠️  Homebrew not found on your system.
Do you want to install Homebrew now? (y/n): y
📦 Installing Homebrew...
# ... Homebrew installation output ...
✅ Homebrew installed successfully!
💡 You might need to open a new terminal or run 'eval "$(grep HOMEBREW_PREFIX /opt/homebrew/bin/brew shellenv | cut -d '=' -f 2 | tr -d ')' | sed 's|^|/|')/bin/brew shellenv)\"' to make 'brew' command available in your current session.
✅ Prerequisites check complete.

📋 Available Packages:
==================================================
1. ⬜ Ruby (via rbenv)
2. ⬜ rbenv (Ruby Version Manager)
3. ⬜ Bundler (Ruby Gem Manager)
# ... more packages ...

🎯 Quick Options:
a. Install all default packages (Ruby (via rbenv), Bundler (Ruby Gem Manager), Git)
q. Quit

💡 You can select multiple packages (e.g., '1,3,5' or '1 3 5')
Enter your choice: a

🔧 Starting installation process...
📦 Will install: rbenv (Ruby Version Manager), Ruby (via rbenv), Bundler (Ruby Gem Manager), Git
⏳ This may take a few minutes...

# ... installation output for each package ...

📊 Installation Summary
==================================================
✅ Successfully installed:
    • rbenv (Ruby Version Manager)
    • Ruby (via rbenv)
    • Bundler (Ruby Gem Manager)
    • Git

🎉 Installation process complete!

Press Enter to continue...
```

---

## 🧩 Adding New Packages

To expand the installer:

1. **Open `install_devenv.rb` in your editor.**
2. **Locate the `PACKAGES` constant** — a Ruby hash mapping package keys to their details.
3. **Add a package** using this template:

```ruby
'your_package_key' => {
  name: 'User-Friendly Package Name',
  command: 'command to install the package', # e.g., 'brew install myapp', 'gem install mygem'
  method: 'homebrew', # or 'gem', 'curl', 'custom_ruby_install', or your custom method
  dependencies: ['dependency_key1', 'dependency_key2'], # Optional
  check_installed_command: 'command to check if installed', # e.g., 'which myapp'
  requires_sudo: false, # Optional
  post_install_commands: ['command1', 'command2'] # Optional
}
```

- **name:** Displayed in the menu.
- **command:** Shell command to install the package.
- **method:** Supported: `homebrew`, `gem`, `curl`, `custom_ruby_install`. To add new methods, implement an `install_your_method_package(package)` function in the `DevEnvInstaller` class and update the `case package[:method]` logic.
- **dependencies:** Array of package keys that must be installed first. Handled automatically.
- **check_installed_command:** Used to check if already installed (return code 0 = installed).
- **requires_sudo:** Set true if root required; prompts for password.
- **post_install_commands:** Additional commands to run after installation.

**To add your package to the default selection:**  
Update the `DEFAULT_PACKAGES` array with your new package key.

---

## 🩺 Troubleshooting

**"command not found" errors**
- Ensure the `command` is correct and in your PATH.
- Restart your terminal or source your shell config (`.zshrc`, `.bashrc`) after installing new tools.

**"Failed to install Homebrew"**
- Ensure `curl` is installed (`which curl`).
- Check your internet connection.
- Try manually running the Homebrew install command shown in the error message.

**Ruby/Gem issues after installing rbenv**
- Make sure rbenv is initialized in your shell (see its post-install message).
- Run `rbenv rehash` if new executables are missing.

**"permission denied" errors**
- Set the `requires_sudo: true` flag for that package in `PACKAGES`.

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

---
