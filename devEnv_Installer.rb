#!/usr/bin/env ruby

require 'io/console' # Required for secure password input

class DevEnvInstaller
  # Define available packages and their installation details
  PACKAGES = {
    'ruby' => {
      name: 'Ruby (via rbenv)',
      method: 'custom_ruby_install',
      dependencies: ['rbenv'], # rbenv must be installed before Ruby
      # Check if a Ruby version is globally active via rbenv
      check_installed_command: 'rbenv global &>/dev/null && rbenv versions | grep "*" &>/dev/null',
      post_install_commands: [] # Post-install for Ruby is handled within custom_ruby_install
    },
    'rbenv' => {
      name: 'rbenv (Ruby Version Manager)',
      command: 'brew install rbenv',
      method: 'homebrew',
      check_installed_command: 'which rbenv',
      # Post-install instructs user to set up rbenv in their shell
      post_install_commands: [
        'echo "If this is a new installation of rbenv, please add the following to your shell configuration (.zshrc, .bashrc, etc.):"',
        'echo \'eval "$(rbenv init -)"\'',
        'echo "Then restart your terminal or run \'eval \\"$(rbenv init -)\\"\'"'
      ]
    },
    'bundler' => {
      name: 'Bundler (Ruby Gem Manager)',
      command: 'gem install bundler --no-document', # --no-document speeds up gem install
      method: 'gem',
      dependencies: ['ruby'],
      check_installed_command: 'which bundle'
    },
    'rails' => {
      name: 'Ruby on Rails',
      command: 'gem install rails --no-document',
      method: 'gem',
      dependencies: ['ruby', 'bundler'],
      check_installed_command: 'which rails'
    },
    'jekyll' => {
      name: 'Jekyll (Static Site Generator)',
      command: 'gem install jekyll --no-document',
      method: 'gem',
      dependencies: ['ruby', 'bundler'],
      check_installed_command: 'which jekyll'
    },
    'rubocop' => {
      name: 'RuboCop - Ruby Linter',
      command: 'gem install rubocop --no-document',
      method: 'gem',
      dependencies: ['ruby'],
      check_installed_command: 'which rubocop'
    },
    'nvm' => {
      name: 'Node.js Version Manager',
      # This curl command installs nvm; the user will then use `nvm install node` separately.
      # Note: nvm needs to be sourced in the shell to be usable. The script will suggest this.
      command: 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash',
      method: 'curl',
      check_installed_command: 'which nvm',
      post_install_commands: [
        'echo "If nvm is new, please close and reopen your terminal or run \'source ~/.nvm/nvm.sh\' for nvm to be available."',
        'echo "Then you can install Node.js using: nvm install --lts"'
      ]
    },
    'luarocks' => {
      name: 'LuaRocks (Lua Package Manager)',
      command: 'brew install luarocks',
      method: 'homebrew',
      check_installed_command: 'which luarocks'
    },
    'luajit' => {
      name: 'LuaJIT (Lua Just-In-Time Compiler)',
      command: 'brew install luajit',
      method: 'homebrew',
      check_installed_command: 'which luajit'
    },
    'gradle' => {
      name: 'Gradle (Build Tool)',
      command: 'brew install gradle',
      method: 'homebrew',
      check_installed_command: 'which gradle'
    },
    'node' => {
      name: 'Node.js',
      command: 'brew install node', # Default to Homebrew for simplicity if nvm isn't chosen
      method: 'homebrew',
      check_installed_command: 'which node'
    },
    'git' => {
      name: 'Git',
      command: 'brew install git',
      method: 'homebrew',
      check_installed_command: 'which git'
    }
  }.freeze

  # Default packages to install if 'all' option is chosen
  DEFAULT_PACKAGES = %w[ruby bundler git].freeze # Removed 'node' as it's often installed via nvm

  def initialize
    @installed_packages = [] # Stores keys of successfully installed packages
    @failed_packages = []    # Stores keys of packages that failed to install
  end

  # Main method to run the installer
  def run
    display_welcome # Show welcome message
    check_prerequisites # Check for essential tools like Homebrew
    
    loop do # Main menu loop
      display_menu # Show package selection menu
      choice = get_user_input # Get user's input

      case choice
      when 'q', 'quit', 'exit'
        display_goodbye # Show goodbye message and exit
        break
      when 'a', 'all'
        install_packages(DEFAULT_PACKAGES) # Install all default packages
      when /^\d+$/ # Single number input
        package_keys = PACKAGES.keys
        index = choice.to_i - 1
        if index >= 0 && index < package_keys.length
          install_packages([package_keys[index]]) # Install the selected single package
        else
          puts "❌ Invalid selection. Please try again."
        end
      when /^[\d,\s]+$/ # Comma or space separated numbers
        indices = choice.split(/[,\s]+/).map(&:to_i).map { |i| i - 1 }
        valid_indices = indices.select { |i| i >= 0 && i < PACKAGES.keys.length }
        if valid_indices.any?
          selected_packages = valid_indices.map { |i| PACKAGES.keys[i] }
          install_packages(selected_packages) # Install multiple selected packages
        else
          puts "❌ Invalid selections. Please try again."
        end
      else
        puts "❌ Invalid option. Please try again."
      end
      
      puts "\nPress Enter to continue..."
      $stdin.gets # Wait for user to press Enter before showing menu again
    end
  end

  private

  # Displays the welcome message
  def display_welcome
    puts <<~WELCOME
      
      🚀 DevEnv Installer
      ==================
      
      Welcome! This tool helps you install development packages quickly and easily.
      
    WELCOME
  end

  # Checks for necessary prerequisites like Homebrew
  def check_prerequisites
    puts "🔍 Checking prerequisites..."
    
    # Check if Homebrew is installed
    unless command_exists?('brew')
      puts "⚠️  Homebrew not found on your system."
      print "Do you want to install Homebrew now? (y/n): "
      response = $stdin.gets.chomp.downcase # Use $stdin.gets for explicit input
      if response == 'y'
        install_homebrew # Install Homebrew if user confirms
      else
        puts "Skipping Homebrew installation. Please be aware that installations of Homebrew-dependent packages may fail."
      end
    end
    
    puts "✅ Prerequisites check complete.\n"
  end

  # Installs Homebrew using its official curl command
  def install_homebrew
    puts "📦 Installing Homebrew..."
    # Official Homebrew installation command
    homebrew_install_cmd = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    
    # Run the installation command
    if run_command(homebrew_install_cmd, requires_sudo: false)
      puts "✅ Homebrew installed successfully!"
      # Attempt to update the script's PATH to include Homebrew binaries
      update_brew_path_for_script
      puts "💡 You might need to open a new terminal or run 'eval \"$(/opt/homebrew/bin/brew shellenv)\"' to make 'brew' command available in your current session."
    else
      puts "❌ Failed to install Homebrew. Please install manually by running the command below in your terminal:"
      puts "   #{homebrew_install_cmd}"
      exit 1 # Exit script if Homebrew installation fails, as it's a core dependency for many packages
    end
  end

  # Attempts to update the current script's PATH environment variable
  # to include Homebrew's binary directory, making `brew` command discoverable.
  def update_brew_path_for_script
    puts "Trying to update PATH for current script session..."
    begin
      # Execute 'brew shellenv' and capture its output
      brew_shellenv_output = `/opt/homebrew/bin/brew shellenv 2>/dev/null`.strip
      
      brew_shellenv_output.each_line do |line|
        if line.start_with?('export ')
          # Parse and set environment variables, handling shell interpolation
          var_name, var_value_raw = line.gsub('export ', '').split('=', 2)
          # Use `eval` to expand shell variables like $PATH within the value,
          # but be cautious with `eval` for untrusted input. Here, it's from `brew shellenv`.
          # Remove surrounding quotes from the value if present
          var_value = var_value_raw.gsub(/^['"]|['"]$/, '')
          
          # Manually expand $PATH for cases like "/opt/homebrew/bin:$PATH"
          if var_value.include?('$PATH')
            ENV[var_name] = var_value.gsub('$PATH', ENV['PATH'].to_s)
          else
            ENV[var_name] = var_value
          end
          puts "  Set ENV['#{var_name}'] to #{ENV[var_name]}"
        end
      end
      # Explicitly add common Homebrew paths if not already there, for robustness
      ENV['PATH'] = "/opt/homebrew/bin:#{ENV['PATH']}" unless ENV['PATH'].include?('/opt/homebrew/bin')
      ENV['PATH'] = "/usr/local/bin:#{ENV['PATH']}" unless ENV['PATH'].include?('/usr/local/bin')
    rescue => e
      puts "⚠️  Could not update PATH for current script: #{e.message}"
      puts "   Some commands might still require a new terminal session."
    end
  end


  # Displays the package selection menu
  def display_menu
    puts "\n📋 Available Packages:"
    puts "=" * 50
    
    # Iterate through packages and display their status (installed/not installed)
    PACKAGES.each_with_index do |(key, package), index|
      status = package_installed?(key) ? "✅" : "⬜"
      puts "#{index + 1}. #{status} #{package[:name]}"
    end
    
    puts "\n🎯 Quick Options:"
    puts "a. Install all default packages (#{DEFAULT_PACKAGES.map { |k| PACKAGES[k][:name] }.join(', ')})"
    puts "q. Quit"
    puts "\n💡 You can select multiple packages (e.g., '1,3,5' or '1 3 5')"
    print "\nEnter your choice: "
  end

  # Gets user input from the console
  def get_user_input
    $stdin.gets.chomp.downcase.strip # Use $stdin.gets for explicit input
  end

  # Checks if a package is already installed
  def package_installed?(package_key)
    package = PACKAGES[package_key]
    return false unless package && package[:check_installed_command]
    
    system(package[:check_installed_command])
  end

  # Runs post-install commands for a package
  def run_post_install_commands(package)
    return unless package[:post_install_commands]
    
    package[:post_install_commands].each do |command|
      system(command)
    end
  end

  # Orchestrates the installation of selected packages, resolving dependencies
  def install_packages(package_keys)
    puts "\n🔧 Starting installation process..."
    
    # Resolve dependencies to ensure correct installation order
    resolved_packages = resolve_dependencies(package_keys)
    
    puts "📦 Will install: #{resolved_packages.map { |k| PACKAGES[k][:name] }.join(', ')}"
    puts "⏳ This may take a few minutes...\n"
    
    resolved_packages.each do |package_key|
      install_package(package_key) # Install each package
    end
    
    display_installation_summary # Show final summary
  end

  # Resolves package dependencies using a simple topological sort
  def resolve_dependencies(package_keys)
    resolved = []
    to_process = package_keys.dup
    
    while to_process.any?
      package_key = to_process.shift
      
      # Skip if already resolved or if package doesn't exist
      next if resolved.include?(package_key) || !PACKAGES.key?(package_key)
      
      package = PACKAGES[package_key]
      unresolved_dependencies = false

      if package[:dependencies] # Check for dependencies
        package[:dependencies].each do |dep|
          unless resolved.include?(dep)
            to_process.unshift(dep) # Add dependency to front of queue
            unresolved_dependencies = true
          end
        end
      end
      
      # If all dependencies are resolved, add current package to resolved list
      unless unresolved_dependencies
        resolved << package_key
      else
        to_process << package_key # Re-add to end if dependencies not yet met
      end

      # Prevent infinite loops in case of unresolvable dependencies (e.g., circular)
      # This simple resolver might loop forever with circular deps.
      # For package managers, this is usually handled by the package manager itself.
      # For this script's scope, we assume no circular dependencies.
      if to_process.size > PACKAGES.keys.length * 2 # Heuristic to detect potential loop
        puts "⚠️  Warning: Could not resolve all dependencies. Some packages might not be installed due to unresolvable dependencies."
        break
      end
    end
    
    resolved.uniq # Ensure unique list and correct order
  end

  # Installs a single package based on its defined method
  def install_package(package_key)
    package = PACKAGES[package_key]
    return unless package # Guard clause if package key is invalid
    
    puts "\n📦 Installing #{package[:name]}..."
    
    if package_installed?(package_key) # Check if already installed
      puts "✅ #{package[:name]} is already installed. Skipping."
      @installed_packages << package_key
      return
    end
    
    # Execute installation command based on method
    success = case package[:method]
              when 'homebrew'
                install_homebrew_package(package)
              when 'custom_ruby_install'
                install_ruby_package(package)
              when 'gem'
                install_gem_package(package)
              when 'curl'
                install_curl_package(package)
              else
                # Default to running the command directly if method is unknown/not specified
                run_command(package[:command], requires_sudo: package[:requires_sudo])
              end
    
    if success
      run_post_install_commands(package) # Run post-install commands
      @installed_packages << package_key
      puts "✅ #{package[:name]} installed successfully!"
    else
      @failed_packages << package_key
      puts "❌ Failed to install #{package[:name]}"
    end
  rescue => e # Catch any unexpected errors during installation
    @failed_packages << package_key
    puts "❌ Error installing #{package[:name]}: #{e.message}"
    puts "   Trace: #{e.backtrace.join("\n   ")}" # Print stack trace for debugging
  end

  # Helper for Homebrew installations
  def install_homebrew_package(package)
    unless command_exists?('brew')
      puts "❌ Homebrew is required for #{package[:name]} but not installed or found in PATH."
      return false
    end
    run_command(package[:command])
  end

  # Custom logic for Ruby installation via rbenv
  def install_ruby_package(package)
    puts "🔍 Installing latest stable Ruby version using rbenv..."
    
    # Ensure rbenv is available in the current script's environment
    # This involves updating PATH to include rbenv shims
    unless ENV['PATH'].include?("$(rbenv root)/shims") || `which rbenv 2>/dev/null`.strip.empty?
      rbenv_root = `rbenv root 2>/dev/null`.strip
      if File.directory?(rbenv_root)
        ENV['PATH'] = "#{rbenv_root}/shims:#{ENV['PATH']}"
        puts "  Updated script's PATH for rbenv shims: #{ENV['PATH']}"
      end
    end

    # If rbenv isn't found even after path update, it's a problem
    unless command_exists?('rbenv')
      puts "❌ rbenv command not found. Cannot install Ruby."
      puts "   Please ensure rbenv is installed and correctly configured in your shell (and restart this script if needed)."
      return false
    end

    # Fetch latest stable Ruby version using a simple alphanumeric sort
    print "Fetching available Ruby versions (this might take a moment)... "
    # List all available versions and filter for stable ones (e.g., 3.2.2)
    available_rubies_output = `rbenv install --list 2>/dev/null`.strip
    latest_stable_ruby = available_rubies_output.split("\n").map(&:strip).select { |v| v =~ /^\d+\.\d+\.\d+$/ }.sort.last

    if latest_stable_ruby
      puts "Found latest stable: #{latest_stable_ruby}"
    else
      puts "Could not determine latest Ruby version. Attempting to install Ruby 3.3.0 as a fallback."
      puts "💡 If 3.3.0 fails or you need a different version, please install it manually after rbenv is set up (e.g., 'rbenv install 3.2.2')."
      latest_stable_ruby = "3.3.0" # Fallback to a known stable version
    end

    # Install the selected Ruby version
    if run_command("rbenv install #{latest_stable_ruby}")
      puts "Setting #{latest_stable_ruby} as global Ruby version..."
      if run_command("rbenv global #{latest_stable_ruby}") # Fixed typo: rbenb -> rbenv
        puts "Running rbenv rehash..."
        if run_command("rbenv rehash")
          puts "✅ Ruby #{latest_stable_ruby} installed and set globally via rbenv."
          return true
        end
      end
    end
    false
  end

  # Helper for Ruby gem installations
  def install_gem_package(package)
    unless command_exists?('ruby')
      puts "❌ Ruby is required for #{package[:name]} but not installed or found in PATH."
      puts "   Please install Ruby first (option 1 in the menu)."
      return false
    end
    run_command(package[:command])
  end

  # Helper for curl installations
  def install_curl_package(package)
    unless command_exists?('curl')
      puts "❌ Curl is required for #{package[:name]} but not installed or found in PATH."
      return false
    end
    run_command(package[:command])
  end

  # Checks if a command exists in the system's PATH
  def command_exists?(command)
    # Use `which` for cross-platform checking if a command is in PATH
    system("which #{command.split.first} >/dev/null 2>&1")
  end

  # Runs a shell command, handles sudo, and provides feedback
  def run_command(command, requires_sudo: false)
    if requires_sudo # Prompt for password if sudo is required
      puts "🔐 This command requires administrator privileges: #{command}"
      print "Enter your password: "
      # Use IO::console.getpass for secure password input (no echo)
      password = IO::console.getpass
      # Prepend password to command using `echo | sudo -S` for non-interactive sudo
      command = "echo '#{password}' | sudo -S #{command}"
    end
    
    # Display the command being run, masking password if present
    display_cmd = command.gsub(/echo '[^']+' \| sudo -S /, 'sudo ')
    puts "⚡ Running: #{display_cmd}"
    
    # Execute the command
    success = system(command)
    
    if success # Check command exit status
      puts "✅ Command completed successfully"
    else
      # $?.exitstatus gives the exit code of the last executed process
      puts "❌ Command failed with exit code: #{$?.exitstatus || 'N/A'}"
    end
    
    success # Return true/false based on command success
  end

  # Displays a summary of installed and failed packages
  def display_installation_summary
    puts "\n" + "=" * 50
    puts "📊 Installation Summary"
    puts "=" * 50
    
    if @installed_packages.any?
      puts "✅ Successfully installed:"
      @installed_packages.each do |pkg|
        puts "    • #{PACKAGES[pkg][:name]}"
      end
    end
    
    if @failed_packages.any?
      puts "\n❌ Failed to install:"
      @failed_packages.each do |pkg|
        puts "    • #{PACKAGES[pkg][:name]}"
      end
      puts "\n💡 Try running the failed installations manually or check the error messages above."
    end
    
    puts "\n🎉 Installation process complete!"
    
    # Clear lists for potential re-runs (though typically script exits after main run)
    @installed_packages.clear
    @failed_packages.clear
  end

  # Displays the goodbye message
  def display_goodbye
    puts "\n👋 Thank you for using DevEnv Installer!"
    puts "Happy coding! 🚀"
  end
end

# Run the installer if this file is executed directly from the command line
if __FILE__ == $0
  installer = DevEnvInstaller.new
  installer.run
end
