# Environment Setup Guide 🛠️

A comprehensive guide to setting up the development environment for iOS projects using Swift and Xcode.

## 📋 Table of Contents

1. [System Requirements](#system-requirements)
2. [Xcode Installation](#xcode-installation)
3. [Command Line Tools](#command-line-tools)
4. [Package Managers](#package-managers)
5. [Development Tools](#development-tools)
6. [Simulator Setup](#simulator-setup)
7. [Device Configuration](#device-configuration)
8. [Environment Variables](#environment-variables)
9. [IDE Configuration](#ide-configuration)
10. [Troubleshooting](#troubleshooting)

## System Requirements

### 💻 Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **Mac Model** | MacBook Air (2018+) | MacBook Pro (2019+) |
| **Processor** | Intel i5 / Apple M1 | Intel i7 / Apple M1 Pro+ |
| **RAM** | 8 GB | 16 GB+ |
| **Storage** | 256 GB SSD | 512 GB+ SSD |
| **macOS** | macOS 12.0+ | Latest macOS |

### 🔧 Software Requirements

```bash
# Check current macOS version
sw_vers

# Expected output:
ProductName:    macOS
ProductVersion: 13.0.0
BuildVersion:   22A380
```

## Xcode Installation

### 📱 Install Xcode

#### Option 1: Mac App Store (Recommended)

1. Open **Mac App Store**
2. Search for **"Xcode"**
3. Click **"Get"** or **"Install"**
4. Wait for download (8-12 GB)

#### Option 2: Apple Developer Portal

1. Visit [developer.apple.com](https://developer.apple.com)
2. Sign in with Apple ID
3. Go to **Downloads**
4. Download **Xcode** (requires Apple Developer account)

### ✅ Verify Xcode Installation

```bash
# Check Xcode version
xcodebuild -version

# Expected output:
Xcode 14.2
Build version 14C18

# Check available SDKs
xcodebuild -showsdks

# List installed simulators
xcrun simctl list devices
```

### 🔧 Xcode Configuration

```bash
# Set Xcode command line tools path
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# Verify command line tools
xcode-select -p
# Should output: /Applications/Xcode.app/Contents/Developer

# Accept Xcode license
sudo xcodebuild -license accept
```

## Command Line Tools

### 🛠️ Install Xcode Command Line Tools

```bash
# Install command line tools
xcode-select --install

# Verify installation
xcode-select -p
gcc --version
make --version
git --version
```

### 📦 Essential Command Line Tools

```bash
# Install Homebrew (package manager)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Verify Homebrew installation
brew --version
brew doctor

# Install essential tools
brew install git
brew install curl
brew install wget
brew install tree
brew install jq
brew install gh  # GitHub CLI
```

## Package Managers

### 📦 Swift Package Manager (Built-in)

```bash
# SPM is included with Xcode
# Verify SPM installation
swift package --version

# Create new Swift package
swift package init --type executable
swift package init --type library

# Build package
swift build

# Run tests
swift test
```

### 🍫 CocoaPods

```bash
# Install CocoaPods
sudo gem install cocoapods

# Verify installation
pod --version

# Setup CocoaPods
pod setup

# Initialize Podfile in project
cd /path/to/your/project
pod init

# Install dependencies
pod install

# Update dependencies
pod update
```

### 📱 Carthage

```bash
# Install Carthage
brew install carthage

# Verify installation
carthage version

# Create Cartfile
echo 'github "Alamofire/Alamofire" ~> 5.6' > Cartfile

# Build dependencies
carthage update --platform iOS
```

## Development Tools

### 🔧 Essential Development Tools

```bash
# Install development tools via Homebrew
brew install --cask sourcetree          # Git GUI
brew install --cask postman             # API testing
brew install --cask charles              # Network proxy
brew install --cask reveal-app           # UI debugging
brew install --cask sf-symbols           # Apple symbols
brew install --cask figma                # Design tool

# Command line tools
brew install swiftlint                   # Swift linting
brew install swiftformat                 # Swift formatting
brew install xcbeautify                  # Xcode output formatting
brew install fastlane                    # iOS automation
```

### 🎨 Design and Prototyping Tools

```bash
# Design tools
brew install --cask sketch
brew install --cask adobe-creative-cloud
brew install --cask principle
brew install --cask zeplin

# Prototyping tools
brew install --cask framer
brew install --cask invision-studio
```

### 📊 Analytics and Monitoring

```bash
# Performance monitoring
brew install --cask instruments         # Built into Xcode
brew install --cask proxyman            # Network debugging
brew install --cask wireshark           # Network analysis
```

## Simulator Setup

### 📱 Install iOS Simulators

```bash
# List available simulators
xcrun simctl list devicetypes

# List available runtimes
xcrun simctl list runtimes

# Install additional simulators through Xcode
# Xcode > Preferences > Components > Simulators
```

### 🔧 Simulator Configuration

```bash
# Create custom simulator
xcrun simctl create "iPhone 14 Pro Custom" \
  "com.apple.CoreSimulator.SimDeviceType.iPhone-14-Pro" \
  "com.apple.CoreSimulator.SimRuntime.iOS-16-2"

# Boot simulator
xcrun simctl boot "iPhone 14 Pro"

# Open Simulator app
open -a Simulator

# Install app on simulator
xcrun simctl install booted /path/to/YourApp.app

# Launch app on simulator
xcrun simctl launch booted com.yourcompany.yourapp

# Reset simulator
xcrun simctl erase "iPhone 14 Pro"

# Delete simulator
xcrun simctl delete "iPhone 14 Pro Custom"
```

### 📋 Recommended Simulator Devices

```bash
# Essential simulators to install:
# - iPhone 14 Pro (latest flagship)
# - iPhone 14 (current standard)
# - iPhone SE (3rd generation) (small screen)
# - iPad Pro (12.9-inch) (tablet)
# - iPad (9th generation) (standard tablet)

# Install via Xcode:
# Xcode > Window > Devices and Simulators > Simulators > +
```

## Device Configuration

### 📱 Physical Device Setup

#### 1. Enable Developer Mode

```bash
# On iOS device:
# Settings > Privacy & Security > Developer Mode > Enable

# On macOS (for iOS 16+):
# System Preferences > Privacy & Security > Developer Tools
```

#### 2. Trust Development Certificate

```bash
# On iOS device after installing app:
# Settings > General > VPN & Device Management
# Select your developer certificate > Trust
```

#### 3. Device Provisioning

```bash
# Add device to Apple Developer Portal
# 1. Get device UDID
# Xcode > Window > Devices and Simulators > Select Device

# 2. Add to developer portal
# developer.apple.com > Certificates, Identifiers & Profiles > Devices

# 3. Update provisioning profiles
# Xcode > Preferences > Accounts > Download Manual Profiles
```

### 🔧 Device Debugging

```bash
# Enable device debugging
# iOS Device: Settings > Developer > Enable UI Automation

# View device logs
xcrun devicectl list devices
xcrun devicectl log stream --device <device-id>

# Install app on device
xcrun devicectl device install app --device <device-id> /path/to/app.ipa

# Launch app on device
xcrun devicectl device process launch --device <device-id> com.yourcompany.yourapp
```

## Environment Variables

### 🔐 Configuration Management

#### 1. Create Environment Configuration

```bash
# Create .env file for project
cat > .env << EOF
# Development Environment
API_BASE_URL=https://api-dev.example.com
API_KEY=dev_api_key_here
DEBUG_MODE=true
LOG_LEVEL=debug

# Analytics
ANALYTICS_KEY=dev_analytics_key
CRASH_REPORTING_KEY=dev_crash_key

# Feature Flags
ENABLE_BETA_FEATURES=true
ENABLE_LOGGING=true
EOF

# Add to .gitignore
echo ".env" >> .gitignore
echo "*.env" >> .gitignore
```

#### 2. Xcode Build Configuration

```bash
# Create configuration files
# Debug.xcconfig
cat > Debug.xcconfig << EOF
#include "Pods/Target Support Files/Pods-YourApp/Pods-YourApp.debug.xcconfig"

API_BASE_URL = https://api-dev.example.com
API_KEY = dev_api_key_here
BUNDLE_ID_SUFFIX = .dev
APP_NAME_SUFFIX =  Dev
EOF

# Release.xcconfig
cat > Release.xcconfig << EOF
#include "Pods/Target Support Files/Pods-YourApp/Pods-YourApp.release.xcconfig"

API_BASE_URL = https://api.example.com
API_KEY = prod_api_key_here
BUNDLE_ID_SUFFIX = 
APP_NAME_SUFFIX = 
EOF
```

#### 3. Swift Configuration

```swift
// Configuration.swift
struct Configuration {
    static let apiBaseURL: String = {
        #if DEBUG
        return "https://api-dev.example.com"
        #else
        return "https://api.example.com"
        #endif
    }()
    
    static let isDebugMode: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    static let logLevel: LogLevel = {
        #if DEBUG
        return .debug
        #else
        return .error
        #endif
    }()
}

// Environment-specific settings
enum Environment {
    case development
    case staging
    case production
    
    static var current: Environment {
        #if DEV
        return .development
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }
    
    var apiBaseURL: String {
        switch self {
        case .development:
            return "https://api-dev.example.com"
        case .staging:
            return "https://api-staging.example.com"
        case .production:
            return "https://api.example.com"
        }
    }
}
```

## IDE Configuration

### ⚙️ Xcode Preferences

#### 1. General Settings

```bash
# Xcode > Preferences > General
# - Issues: Show live issues
# - File Extensions: Show all
# - Dialog Warnings: Enable all
```

#### 2. Text Editing

```bash
# Xcode > Preferences > Text Editing
# Indentation:
# - Prefer indent using: Spaces
# - Tab width: 4
# - Indent width: 4
# - Tab key: Indents in leading whitespace

# Editing:
# - Automatically trim trailing whitespace
# - Including whitespace-only lines
# - Show invisible characters
```

#### 3. Source Control

```bash
# Xcode > Preferences > Source Control
# General:
# - Enable source control
# - Refresh local status automatically
# - Fetch and refresh server status automatically
# - Add and remove files automatically
# - Select files to commit automatically

# Git:
# - Author name: Your Name
# - Author email: your.email@company.com
```

#### 4. Behaviors

```bash
# Xcode > Preferences > Behaviors
# Running:
# - Starts: Show navigator - Debug navigator
# - Generates new issues: Show navigator - Issue navigator

# Testing:
# - Starts: Show navigator - Test navigator
# - Fails: Show navigator - Issue navigator
```

### 🎨 Code Formatting

#### 1. SwiftLint Configuration

```yaml
# .swiftlint.yml
disabled_rules:
  - trailing_whitespace
  - line_length

opt_in_rules:
  - empty_count
  - empty_string
  - first_where
  - sorted_imports
  - vertical_parameter_alignment_on_call

included:
  - Sources
  - Tests

excluded:
  - Carthage
  - Pods
  - DerivedData

line_length:
  warning: 120
  error: 150
  ignores_urls: true
  ignores_function_declarations: true
  ignores_comments: true

function_body_length:
  warning: 50
  error: 100

type_body_length:
  warning: 300
  error: 500

file_length:
  warning: 500
  error: 1000

identifier_name:
  min_length:
    warning: 2
    error: 1
  max_length:
    warning: 40
    error: 50
  excluded:
    - id
    - URL
    - url
```

#### 2. SwiftFormat Configuration

```bash
# .swiftformat
--indent 4
--tabwidth 4
--maxwidth 120
--wraparguments before-first
--wrapcollections before-first
--closingparen same-line
--commas inline
--trimwhitespace always
--insertlines enabled
--removelines enabled
--allman false
--stripunusedargs closure-only
--self remove
--importgrouping testable-bottom
--ifdef no-indent
```

### 🔧 Build Scripts

#### 1. SwiftLint Build Phase

```bash
# Add to Xcode Build Phases > New Run Script Phase
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

#### 2. SwiftFormat Build Phase

```bash
# Add to Xcode Build Phases > New Run Script Phase
if which swiftformat >/dev/null; then
  swiftformat .
else
  echo "warning: SwiftFormat not installed, download from https://github.com/nicklockwood/SwiftFormat"
fi
```

## Troubleshooting

### 🔧 Common Issues

#### 1. Xcode Command Line Tools Issues

```bash
# Reset command line tools
sudo xcode-select --reset
xcode-select --install

# Fix missing headers
sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /
```

#### 2. Simulator Issues

```bash
# Reset all simulators
xcrun simctl erase all

# Restart Simulator service
sudo killall -9 com.apple.CoreSimulator.CoreSimulatorService

# Clear Simulator cache
rm -rf ~/Library/Developer/CoreSimulator/Caches
```

#### 3. Derived Data Issues

```bash
# Clear Derived Data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clear Module Cache
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex

# Clean build folder in Xcode
# Product > Clean Build Folder (Cmd+Shift+K)
```

#### 4. Provisioning Profile Issues

```bash
# Delete all provisioning profiles
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles

# Re-download profiles
# Xcode > Preferences > Accounts > Download Manual Profiles

# Reset keychain
# Keychain Access > Keychain First Aid
```

#### 5. CocoaPods Issues

```bash
# Update CocoaPods
sudo gem update cocoapods

# Clear CocoaPods cache
pod cache clean --all

# Reinstall pods
rm -rf Pods
rm Podfile.lock
pod install

# Fix repository issues
pod repo remove master
pod setup
```

### 🆘 Emergency Recovery

#### 1. Complete Xcode Reset

```bash
# ⚠️ This will remove all Xcode data
# Backup important projects first!

# Remove Xcode preferences
rm -rf ~/Library/Preferences/com.apple.dt.Xcode.plist
rm -rf ~/Library/Saved\ Application\ State/com.apple.dt.Xcode.savedState

# Remove Xcode caches
rm -rf ~/Library/Caches/com.apple.dt.Xcode
rm -rf ~/Library/Developer/Xcode

# Reinstall Xcode
# Download from Mac App Store or Developer Portal
```

#### 2. System Recovery

```bash
# Reset system development environment
# ⚠️ This will remove all development tools

# Remove Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# Remove command line tools
sudo rm -rf /Library/Developer/CommandLineTools

# Reinstall everything
# Follow installation steps from beginning
```

---

## 📋 Setup Checklist

### ✅ Essential Setup

- [ ] **macOS**: Latest version installed
- [ ] **Xcode**: Latest version from App Store
- [ ] **Command Line Tools**: Installed and configured
- [ ] **Homebrew**: Installed and updated
- [ ] **Git**: Configured with user details
- [ ] **Simulators**: Essential devices installed
- [ ] **SwiftLint**: Installed and configured
- [ ] **SwiftFormat**: Installed and configured

### ✅ Optional Tools

- [ ] **CocoaPods**: For dependency management
- [ ] **Carthage**: Alternative dependency manager
- [ ] **Fastlane**: For automation
- [ ] **SourceTree**: Git GUI client
- [ ] **Charles**: Network debugging
- [ ] **Reveal**: UI debugging
- [ ] **SF Symbols**: Apple symbol library

### ✅ Project Setup

- [ ] **Environment Variables**: Configured for different environments
- [ ] **Build Configurations**: Debug/Release settings
- [ ] **Code Formatting**: SwiftLint and SwiftFormat rules
- [ ] **Git Configuration**: Repository and workflows
- [ ] **CI/CD**: Automated testing and deployment

---

**Remember**: A well-configured development environment is the foundation of productive iOS development. Take time to set it up properly! 🚀