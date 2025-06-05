DevEnv Installer
Description
The DevEnv Installer is a Ruby command-line interface (CLI) tool designed to streamline the setup of your development environment by automating the installation of common packages. It allows you to select individual packages or install a predefined set of defaults, handling dependencies and prompting for administrator privileges when necessary.

Features
Interactive CLI: Easy-to-use menu for package selection.

Modular Design: Easily add new packages and installation methods.

Dependency Resolution: Automatically installs package dependencies in the correct order.

Homebrew Integration: Leverages Homebrew for macOS package management.

Curl & Gem Integration: Uses curl for script-based installations and gem for Ruby libraries.

Sudo Prompting: Securely prompts for your password if a command requires root privileges.

Installation Summary: Provides a clear overview of successful and failed installations.

Prerequisites
Before running this script, ensure you have the following:

Ruby: You need Ruby installed on your system to run the script itself.

macOS: Ruby usually comes pre-installed. If not, you can install it via your system's package manager (e.g., Homebrew, which this script can help you install).

Linux: Use your distribution's package manager (e.g., sudo apt install ruby on Debian/Ubuntu, sudo dnf install ruby on Fedora).

Git: Required for some curl installations that fetch content from GitHub.

Internet Connection: Necessary to download packages and installation scripts.

How to Use
1. Download the Script
Save the provided Ruby code into a file named install_devenv.rb (or any .rb extension).

2. Make the Script Executable
Open your terminal and run the following command to give the script execution permissions:

chmod +x install_devenv.rb

3. Run the Installer
Execute the script from your terminal:

./install_devenv.rb

4. Follow the Prompts
The script will guide you through the process:

It will first check for Homebrew. If not found, it will ask if you want to install it. Type y and press Enter to proceed with Homebrew installation (recommended for macOS users).

The main menu will display a list of available packages.

To select a single package: Enter its corresponding number (e.g., 1 for Ruby) and press Enter.

To select multiple packages: Enter their numbers separated by commas or spaces (e.g., 1,3,5 or 1 3 5) and press Enter.

To install all default packages: Type a or all and press Enter.

To quit: Type q, quit, or exit and press Enter.

Example Workflow
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

How to Expand/Add New Packages
The script is designed for easy expansion. To add a new package:

Open install_devenv.rb in your text editor.

Locate the PACKAGES constant. This is a Ruby hash where each key represents a package identifier, and its value is a hash containing package details.

Add a new entry to the PACKAGES hash following this structure:

'your_package_key' => {
  name: 'User-Friendly Package Name',
  command: 'command to install the package', # e.g., 'brew install myapp', 'gem install mygem'
  method: 'homebrew', # or 'gem', 'curl', 'custom_ruby_install', or a new custom method
  dependencies: ['dependency_key1', 'dependency_key2'], # Optional: other package keys it depends on
  check_installed_command: 'command to check if it\'s installed', # e.g., 'which myapp', 'myapp --version'
  requires_sudo: false, # Optional: set to true if `sudo` is needed for `command`
  post_install_commands: ['command1', 'command2'] # Optional: array of commands to run after installation
},

name: What the user sees in the menu.

command: The actual shell command to execute for installation.

method: Categorizes the installation type. Currently supported: homebrew, gem, curl, custom_ruby_install. If you need a new method, you'll also need to add a corresponding install_your_method_package(package) function within the DevEnvInstaller class and update the case package[:method] statement in install_package.

dependencies: An array of package_key strings that must be installed before this package. The script will resolve these automatically.

check_installed_command: A shell command used to determine if the package is already installed. If this command exits successfully (returns 0), the package is considered installed.

requires_sudo: Set to true if the command requires sudo privileges. The script will prompt for a password.

post_install_commands: An array of additional shell commands to run after the main installation command completes successfully.

Update DEFAULT_PACKAGES (Optional):
If you want your new package to be part of the "install all default packages" option, add its package_key to the DEFAULT_PACKAGES array.

Troubleshooting
"command not found" errors:

Ensure the command is correctly spelled in PACKAGES.

Verify the command is in your system's PATH. For Homebrew or nvm installations, you might need to restart your terminal or source your shell's configuration file (e.g., ~/.zshrc, ~/.bashrc) after the initial installation for the new commands to be available in your current session. The script attempts to update its own PATH, but a full shell reload is often best.

"Failed to install Homebrew":

Ensure you have curl installed (which curl).

Check your internet connection.

Try running the Homebrew installation command provided in the error message manually.

Ruby or Gem installation issues after rbenv:

Make sure rbenv is correctly initialized in your shell. The rbenv post_install_commands provides instructions on how to do this.

Run rbenv rehash if new executables (like bundle or rails) aren't found after gem install.

"Error installing...: permission denied":

This usually means the installation command requires sudo but the requires_sudo: true flag was not set for that package in the PACKAGES definition. Update the package definition accordingly.

License
This project is open-source and available under the MIT License.
