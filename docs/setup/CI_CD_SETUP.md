# CI/CD Setup Guide 🚀

A comprehensive guide to setting up Continuous Integration and Continuous Deployment for iOS projects using modern tools and best practices.

## 📋 Table of Contents

1. [Overview](#overview)
2. [GitHub Actions](#github-actions)
3. [Fastlane Configuration](#fastlane-configuration)
4. [Xcode Cloud](#xcode-cloud)
5. [Jenkins Setup](#jenkins-setup)
6. [Code Quality Integration](#code-quality-integration)
7. [Testing Automation](#testing-automation)
8. [Deployment Strategies](#deployment-strategies)
9. [Monitoring & Analytics](#monitoring--analytics)
10. [Troubleshooting](#troubleshooting)

## Overview

### 🎯 CI/CD Goals

- **Automated Testing**: Run unit, integration, and UI tests on every commit
- **Code Quality**: Enforce coding standards and detect issues early
- **Automated Builds**: Generate builds for different environments
- **Deployment Automation**: Deploy to TestFlight and App Store
- **Feedback Loop**: Provide quick feedback to developers
- **Release Management**: Streamline release processes

### 🏗️ CI/CD Pipeline Architecture

```
📝 Code Commit
    ↓
🔍 Code Quality Checks (SwiftLint, SwiftFormat)
    ↓
🧪 Automated Testing (Unit, Integration, UI)
    ↓
🏗️ Build Generation (Debug, Release)
    ↓
📊 Code Coverage & Reports
    ↓
🚀 Deployment (TestFlight, App Store)
    ↓
📈 Monitoring & Analytics
```

### 🛠️ Tool Comparison

| Tool | Pros | Cons | Best For |
|------|------|------|----------|
| **GitHub Actions** | Free, integrated, flexible | Limited macOS minutes | Open source, GitHub repos |
| **Xcode Cloud** | Native Apple integration | Paid, limited customization | Apple ecosystem |
| **Fastlane** | Powerful automation | Setup complexity | Complex workflows |
| **Jenkins** | Highly customizable | Self-hosted, maintenance | Enterprise, custom needs |
| **CircleCI** | Good performance | Paid for private repos | Professional teams |
| **Bitrise** | iOS-focused | Paid plans | Mobile-first teams |

## GitHub Actions

### 🔄 Basic Workflow

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Monday at 2 AM

env:
  DEVELOPER_DIR: /Applications/Xcode_15.0.app/Contents/Developer
  IOS_SIMULATOR_UDID: "iPhone 15 Pro"

jobs:
  code-quality:
    name: Code Quality Checks
    runs-on: macos-14
    
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
    
    - name: Cache Dependencies
      uses: actions/cache@v3
      with:
        path: |
          ~/.cache/pip
          ~/Library/Caches/com.github.sindresorhus.Defaults
        key: ${{ runner.os }}-deps-${{ hashFiles('**/Podfile.lock', '**/Package.resolved') }}
        restore-keys: |
          ${{ runner.os }}-deps-
    
    - name: Install SwiftLint
      run: |
        if ! command -v swiftlint &> /dev/null; then
          brew install swiftlint
        fi
    
    - name: Install SwiftFormat
      run: |
        if ! command -v swiftformat &> /dev/null; then
          brew install swiftformat
        fi
    
    - name: SwiftLint Check
      run: |
        swiftlint --strict --reporter github-actions-logging
    
    - name: SwiftFormat Check
      run: |
        swiftformat --lint . --reporter github-actions-logging
    
    - name: Check for TODO/FIXME
      run: |
        if grep -r "TODO\|FIXME" --include="*.swift" .; then
          echo "⚠️ Found TODO/FIXME comments. Please resolve before merging."
          exit 1
        fi

  unit-tests:
    name: Unit Tests
    runs-on: macos-14
    needs: code-quality
    
    strategy:
      matrix:
        destination:
          - "platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0"
          - "platform=iOS Simulator,name=iPhone 15,OS=17.0"
          - "platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation),OS=17.0"
    
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
    
    - name: Select Xcode Version
      run: sudo xcode-select -s $DEVELOPER_DIR
    
    - name: Cache SPM Dependencies
      uses: actions/cache@v3
      with:
        path: .build
        key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}
        restore-keys: |
          ${{ runner.os }}-spm-
    
    - name: Resolve Dependencies
      run: |
        xcodebuild -resolvePackageDependencies -scheme MyAwesomeApp
    
    - name: Build for Testing
      run: |
        xcodebuild build-for-testing \
          -scheme MyAwesomeApp \
          -destination "${{ matrix.destination }}" \
          -derivedDataPath DerivedData \
          CODE_SIGNING_ALLOWED=NO
    
    - name: Run Unit Tests
      run: |
        xcodebuild test-without-building \
          -scheme MyAwesomeApp \
          -destination "${{ matrix.destination }}" \
          -derivedDataPath DerivedData \
          -enableCodeCoverage YES \
          -only-testing:MyAwesomeAppTests \
          CODE_SIGNING_ALLOWED=NO
    
    - name: Generate Code Coverage Report
      if: matrix.destination == 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0'
      run: |
        xcrun xccov view --report --json DerivedData/Logs/Test/*.xcresult > coverage.json
        xcrun xccov view --report DerivedData/Logs/Test/*.xcresult
    
    - name: Upload Coverage to Codecov
      if: matrix.destination == 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0'
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.json
        fail_ci_if_error: false
        verbose: true

  ui-tests:
    name: UI Tests
    runs-on: macos-14
    needs: unit-tests
    if: github.event_name == 'push' || github.event.pull_request.draft == false
    
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
    
    - name: Select Xcode Version
      run: sudo xcode-select -s $DEVELOPER_DIR
    
    - name: Cache Dependencies
      uses: actions/cache@v3
      with:
        path: .build
        key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}
        restore-keys: |
          ${{ runner.os }}-spm-
    
    - name: Run UI Tests
      run: |
        xcodebuild test \
          -scheme MyAwesomeApp \
          -destination "platform=iOS Simulator,name=$IOS_SIMULATOR_UDID,OS=17.0" \
          -only-testing:MyAwesomeAppUITests \
          -derivedDataPath DerivedData \
          CODE_SIGNING_ALLOWED=NO
    
    - name: Upload UI Test Results
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: ui-test-results
        path: DerivedData/Logs/Test/*.xcresult

  build-archive:
    name: Build Archive
    runs-on: macos-14
    needs: [unit-tests, ui-tests]
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
    
    - name: Select Xcode Version
      run: sudo xcode-select -s $DEVELOPER_DIR
    
    - name: Import Code Signing Certificates
      uses: apple-actions/import-codesign-certs@v2
      with:
        p12-file-base64: ${{ secrets.CERTIFICATES_P12 }}
        p12-password: ${{ secrets.CERTIFICATES_PASSWORD }}
    
    - name: Download Provisioning Profiles
      uses: apple-actions/download-provisioning-profiles@v1
      with:
        bundle-id: com.yourcompany.myawesomeapp
        issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
        api-key-id: ${{ secrets.APPSTORE_KEY_ID }}
        api-private-key: ${{ secrets.APPSTORE_PRIVATE_KEY }}
    
    - name: Build Archive
      run: |
        xcodebuild archive \
          -scheme MyAwesomeApp \
          -configuration Release \
          -archivePath MyAwesomeApp.xcarchive \
          -allowProvisioningUpdates
    
    - name: Export IPA
      run: |
        xcodebuild -exportArchive \
          -archivePath MyAwesomeApp.xcarchive \
          -exportPath . \
          -exportOptionsPlist ExportOptions.plist
    
    - name: Upload to TestFlight
      if: success()
      run: |
        xcrun altool --upload-app \
          --type ios \
          --file MyAwesomeApp.ipa \
          --username ${{ secrets.APPSTORE_USERNAME }} \
          --password ${{ secrets.APPSTORE_PASSWORD }}
    
    - name: Upload Build Artifacts
      uses: actions/upload-artifact@v3
      with:
        name: build-artifacts
        path: |
          MyAwesomeApp.ipa
          MyAwesomeApp.xcarchive

  security-scan:
    name: Security Scan
    runs-on: macos-14
    needs: code-quality
    
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
    
    - name: Run Security Scan
      run: |
        # Check for hardcoded secrets
        if grep -r "password\|secret\|key\|token" --include="*.swift" --exclude-dir=Tests .; then
          echo "⚠️ Potential hardcoded secrets found. Please review."
        fi
        
        # Check for insecure network calls
        if grep -r "http://" --include="*.swift" .; then
          echo "⚠️ Insecure HTTP calls found. Use HTTPS instead."
          exit 1
        fi
    
    - name: Dependency Vulnerability Check
      run: |
        # Add dependency vulnerability scanning here
        echo "Checking dependencies for vulnerabilities..."
```

### 🔐 Secrets Configuration

```bash
# Required GitHub Secrets:
# Repository Settings > Secrets and variables > Actions

APPSTORE_USERNAME          # Apple ID email
APPSTORE_PASSWORD          # App-specific password
APPSTORE_ISSUER_ID         # App Store Connect API issuer ID
APPSTORE_KEY_ID            # App Store Connect API key ID
APPSTORE_PRIVATE_KEY       # App Store Connect API private key
CERTIFICATES_P12           # Base64 encoded .p12 certificate
CERTIFICATES_PASSWORD      # Certificate password
CODECOV_TOKEN             # Codecov upload token
SLACK_WEBHOOK_URL         # Slack notifications (optional)
```

### 📱 Export Options

```xml
<!-- ExportOptions.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>manageAppVersionAndBuildNumber</key>
    <false/>
    <key>destination</key>
    <string>upload</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
</dict>
</plist>
```

## Fastlane Configuration

### 🚀 Fastfile Setup

```ruby
# fastlane/Fastfile
default_platform(:ios)

# Constants
SCHEME = "MyAwesomeApp"
WORKSPACE = "MyAwesomeApp.xcworkspace"
PROJECT = "MyAwesomeApp.xcodeproj"

platform :ios do
  
  before_all do
    setup_circle_ci if ENV['CI']
    ensure_git_status_clean unless ENV['CI']
  end
  
  # MARK: - Testing Lanes
  
  desc "Run all tests"
  lane :test do
    run_tests(
      workspace: WORKSPACE,
      scheme: SCHEME,
      device: "iPhone 15 Pro",
      code_coverage: true,
      output_directory: "./test_output",
      output_types: "html,junit"
    )
  end
  
  desc "Run unit tests only"
  lane :test_unit do
    run_tests(
      workspace: WORKSPACE,
      scheme: SCHEME,
      device: "iPhone 15 Pro",
      only_testing: ["MyAwesomeAppTests"],
      code_coverage: true
    )
  end
  
  desc "Run UI tests only"
  lane :test_ui do
    run_tests(
      workspace: WORKSPACE,
      scheme: SCHEME,
      device: "iPhone 15 Pro",
      only_testing: ["MyAwesomeAppUITests"]
    )
  end
  
  # MARK: - Code Quality Lanes
  
  desc "Run code quality checks"
  lane :quality do
    swiftlint(
      mode: :lint,
      strict: true,
      reporter: "emoji"
    )
    
    swiftformat(
      lint: true
    )
  end
  
  desc "Fix code formatting"
  lane :format do
    swiftformat
  end
  
  # MARK: - Build Lanes
  
  desc "Build for development"
  lane :build_dev do
    build_app(
      workspace: WORKSPACE,
      scheme: SCHEME,
      configuration: "Debug",
      skip_archive: true,
      skip_codesigning: true,
      destination: "generic/platform=iOS Simulator"
    )
  end
  
  desc "Build for testing"
  lane :build_for_testing do
    build_for_testing(
      workspace: WORKSPACE,
      scheme: SCHEME,
      configuration: "Debug",
      destination: "generic/platform=iOS Simulator"
    )
  end
  
  # MARK: - Release Lanes
  
  desc "Increment version number"
  lane :bump_version do |options|
    version_type = options[:type] || "patch"
    
    increment_version_number(
      bump_type: version_type,
      xcodeproj: PROJECT
    )
    
    increment_build_number(
      xcodeproj: PROJECT
    )
    
    commit_version_bump(
      xcodeproj: PROJECT,
      message: "Version bump to #{get_version_number}"
    )
  end
  
  desc "Create release tag"
  lane :tag_release do
    version = get_version_number(xcodeproj: PROJECT)
    build = get_build_number(xcodeproj: PROJECT)
    tag_name = "v#{version}-#{build}"
    
    add_git_tag(
      tag: tag_name,
      message: "Release #{tag_name}"
    )
    
    push_git_tags
  end
  
  # MARK: - Deployment Lanes
  
  desc "Deploy to TestFlight"
  lane :beta do
    ensure_git_branch(branch: "main")
    
    # Increment build number
    increment_build_number(
      xcodeproj: PROJECT
    )
    
    # Build and archive
    build_app(
      workspace: WORKSPACE,
      scheme: SCHEME,
      configuration: "Release",
      export_method: "app-store",
      export_options: {
        uploadBitcode: false,
        uploadSymbols: true,
        compileBitcode: false,
        manageAppVersionAndBuildNumber: false
      }
    )
    
    # Upload to TestFlight
    upload_to_testflight(
      skip_waiting_for_build_processing: true,
      notify_external_testers: false,
      changelog: generate_changelog
    )
    
    # Commit version bump
    commit_version_bump(
      xcodeproj: PROJECT,
      message: "TestFlight build #{get_build_number}"
    )
    
    # Send notification
    slack(
      message: "🚀 New TestFlight build available: #{get_version_number} (#{get_build_number})",
      channel: "#ios-releases"
    ) if ENV['SLACK_URL']
  end
  
  desc "Deploy to App Store"
  lane :release do
    ensure_git_branch(branch: "main")
    ensure_git_status_clean
    
    # Run tests before release
    test
    
    # Increment version
    bump_version(type: "minor")
    
    # Build and archive
    build_app(
      workspace: WORKSPACE,
      scheme: SCHEME,
      configuration: "Release",
      export_method: "app-store"
    )
    
    # Upload to App Store
    upload_to_app_store(
      force: true,
      submit_for_review: false,
      automatic_release: false,
      skip_metadata: false,
      skip_screenshots: false
    )
    
    # Create release tag
    tag_release
    
    # Send notification
    slack(
      message: "📱 New App Store release submitted: #{get_version_number}",
      channel: "#ios-releases"
    ) if ENV['SLACK_URL']
  end
  
  # MARK: - Utility Lanes
  
  desc "Generate changelog from git commits"
  lane :changelog do
    changelog_from_git_commits(
      pretty: "- %s",
      date_format: "short",
      match_lightweight_tag: false,
      merge_commit_filtering: "exclude_merges"
    )
  end
  
  desc "Clean build artifacts"
  lane :clean do
    clear_derived_data
    clean_build_artifacts
  end
  
  desc "Setup development environment"
  lane :setup do
    cocoapods if File.exist?("Podfile")
    
    # Install development tools
    sh "brew install swiftlint swiftformat" rescue nil
    
    UI.success "🎉 Development environment setup complete!"
  end
  
  # MARK: - Error Handling
  
  error do |lane, exception|
    slack(
      message: "❌ Lane #{lane} failed: #{exception.message}",
      channel: "#ios-ci",
      success: false
    ) if ENV['SLACK_URL']
  end
  
  # MARK: - Private Methods
  
  private_lane :generate_changelog do
    changelog_from_git_commits(
      pretty: "- %s",
      date_format: "short",
      match_lightweight_tag: false,
      merge_commit_filtering: "exclude_merges"
    )
  end
end
```

### 📋 Fastfile Configuration

```ruby
# fastlane/Appfile
app_identifier("com.yourcompany.myawesomeapp")
apple_id("your.email@example.com")
team_id("YOUR_TEAM_ID")

# App Store Connect API
itc_team_id("YOUR_ITC_TEAM_ID")

# For multiple targets
for_platform :ios do
  for_lane :beta do
    app_identifier("com.yourcompany.myawesomeapp")
  end
  
  for_lane :release do
    app_identifier("com.yourcompany.myawesomeapp")
  end
end
```

### 🔧 Fastlane Plugins

```ruby
# fastlane/Pluginfile
gem 'fastlane-plugin-versioning'
gem 'fastlane-plugin-changelog'
gem 'fastlane-plugin-slack'
gem 'fastlane-plugin-codecov'
gem 'fastlane-plugin-swiftlint'
gem 'fastlane-plugin-swiftformat'
gem 'fastlane-plugin-firebase_app_distribution'
```

## Xcode Cloud

### ☁️ Xcode Cloud Configuration

```yaml
# ci_scripts/ci_post_clone.sh
#!/bin/sh

# Install dependencies
if [ -f "Podfile" ]; then
    echo "Installing CocoaPods dependencies..."
    pod install
fi

# Install SwiftLint
echo "Installing SwiftLint..."
brew install swiftlint

# Install SwiftFormat
echo "Installing SwiftFormat..."
brew install swiftformat

# Set up environment variables
echo "Setting up environment..."
export CI=true
export XCODE_CLOUD=true

echo "Post-clone setup complete!"
```

```yaml
# ci_scripts/ci_pre_xcodebuild.sh
#!/bin/sh

# Run SwiftLint
echo "Running SwiftLint..."
swiftlint --strict

# Run SwiftFormat check
echo "Running SwiftFormat check..."
swiftformat --lint .

echo "Pre-build checks complete!"
```

```yaml
# ci_scripts/ci_post_xcodebuild.sh
#!/bin/sh

# Generate test reports
echo "Generating test reports..."

# Upload coverage if needed
if [ "$CI_WORKFLOW" = "Test" ]; then
    echo "Uploading code coverage..."
    # Add coverage upload logic here
fi

# Send notifications
if [ "$CI_WORKFLOW" = "Deploy" ]; then
    echo "Sending deployment notification..."
    # Add notification logic here
fi

echo "Post-build tasks complete!"
```

### 📱 Xcode Cloud Workflows

```json
{
  "version": 1,
  "workflows": {
    "Test": {
      "name": "Test",
      "description": "Run tests on every commit",
      "trigger": {
        "branches": ["main", "develop"],
        "pullRequests": true
      },
      "actions": [
        {
          "name": "Test",
          "scheme": "MyAwesomeApp",
          "platform": "iOS",
          "destination": "iPhone 15 Pro Simulator"
        }
      ]
    },
    "Deploy to TestFlight": {
      "name": "Deploy to TestFlight",
      "description": "Deploy to TestFlight on main branch",
      "trigger": {
        "branches": ["main"]
      },
      "actions": [
        {
          "name": "Archive",
          "scheme": "MyAwesomeApp",
          "platform": "iOS",
          "destination": "Any iOS Device"
        },
        {
          "name": "TestFlight",
          "destination": "TestFlight"
        }
      ]
    }
  }
}
```

## Jenkins Setup

### 🏗️ Jenkins Pipeline

```groovy
// Jenkinsfile
pipeline {
    agent {
        label 'macos'
    }
    
    environment {
        DEVELOPER_DIR = '/Applications/Xcode.app/Contents/Developer'
        FASTLANE_SKIP_UPDATE_CHECK = '1'
        FASTLANE_HIDE_CHANGELOG = '1'
    }
    
    options {
        timeout(time: 60, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git clean -fdx'
            }
        }
        
        stage('Setup') {
            steps {
                sh '''
                    # Install dependencies
                    if [ -f "Podfile" ]; then
                        pod install
                    fi
                    
                    # Install tools
                    brew install swiftlint swiftformat || true
                '''
            }
        }
        
        stage('Code Quality') {
            parallel {
                stage('SwiftLint') {
                    steps {
                        sh 'swiftlint --reporter junit > swiftlint-results.xml || true'
                    }
                    post {
                        always {
                            publishTestResults(
                                testResultsPattern: 'swiftlint-results.xml',
                                allowEmptyResults: true
                            )
                        }
                    }
                }
                
                stage('SwiftFormat') {
                    steps {
                        sh 'swiftformat --lint .'
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                sh '''
                    fastlane test
                '''
            }
            post {
                always {
                    publishTestResults(
                        testResultsPattern: 'test_output/report.junit',
                        allowEmptyResults: true
                    )
                    
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'test_output',
                        reportFiles: 'report.html',
                        reportName: 'Test Report'
                    ])
                }
            }
        }
        
        stage('Build') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                sh 'fastlane build_for_testing'
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([
                    string(credentialsId: 'appstore-password', variable: 'FASTLANE_PASSWORD')
                ]) {
                    sh 'fastlane beta'
                }
            }
        }
    }
    
    post {
        always {
            archiveArtifacts(
                artifacts: '**/*.ipa,**/*.xcarchive',
                allowEmptyArchive: true
            )
        }
        
        success {
            slackSend(
                channel: '#ios-ci',
                color: 'good',
                message: "✅ Build succeeded: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
            )
        }
        
        failure {
            slackSend(
                channel: '#ios-ci',
                color: 'danger',
                message: "❌ Build failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
            )
        }
    }
}
```

## Code Quality Integration

### 🔍 SonarQube Integration

```yaml
# sonar-project.properties
sonar.projectKey=myawesomeapp-ios
sonar.projectName=MyAwesome App iOS
sonar.projectVersion=1.0

# Source directories
sonar.sources=MyAwesomeApp
sonar.tests=MyAwesomeAppTests,MyAwesomeAppUITests

# Language
sonar.language=swift

# Exclusions
sonar.exclusions=**/*.generated.swift,**/Pods/**,**/DerivedData/**

# Test results
sonar.swift.coverage.reportPaths=test_output/coverage.xml
sonar.swift.swiftlint.reportPaths=swiftlint-results.xml
```

### 📊 Code Coverage

```bash
#!/bin/bash
# scripts/generate_coverage.sh

# Generate coverage report
xcrun xccov view --report --json DerivedData/Logs/Test/*.xcresult > coverage.json

# Convert to Cobertura format for SonarQube
python3 scripts/xccov_to_cobertura.py coverage.json > coverage.xml

# Upload to Codecov
if [ "$CI" = "true" ]; then
    bash <(curl -s https://codecov.io/bash) -f coverage.xml
fi
```

## Testing Automation

### 🧪 Parallel Testing

```yaml
# .github/workflows/parallel-tests.yml
name: Parallel Tests

on:
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: macos-14
    strategy:
      matrix:
        test-plan:
          - UnitTests
          - IntegrationTests
          - UITests
        device:
          - "iPhone 15 Pro"
          - "iPad Pro (12.9-inch) (6th generation)"
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4
    
    - name: Run Tests
      run: |
        xcodebuild test \
          -scheme MyAwesomeApp \
          -testPlan ${{ matrix.test-plan }} \
          -destination "platform=iOS Simulator,name=${{ matrix.device }}" \
          CODE_SIGNING_ALLOWED=NO
```

### 🎯 Test Plans

```json
{
  "configurations" : [
    {
      "id" : "unit-tests",
      "name" : "Unit Tests",
      "options" : {
        "codeCoverage" : true,
        "testTimeoutsEnabled" : true
      }
    },
    {
      "id" : "integration-tests",
      "name" : "Integration Tests",
      "options" : {
        "codeCoverage" : false,
        "testTimeoutsEnabled" : true
      }
    },
    {
      "id" : "ui-tests",
      "name" : "UI Tests",
      "options" : {
        "codeCoverage" : false,
        "testTimeoutsEnabled" : true
      }
    }
  ],
  "defaultOptions" : {
    "codeCoverage" : false,
    "testTimeoutsEnabled" : false
  },
  "testTargets" : [
    {
      "target" : {
        "containerPath" : "container:MyAwesomeApp.xcodeproj",
        "identifier" : "MyAwesomeAppTests",
        "name" : "MyAwesomeAppTests"
      }
    },
    {
      "target" : {
        "containerPath" : "container:MyAwesomeApp.xcodeproj",
        "identifier" : "MyAwesomeAppUITests",
        "name" : "MyAwesomeAppUITests"
      }
    }
  ],
  "version" : 1
}
```

## Deployment Strategies

### 🚀 Blue-Green Deployment

```ruby
# fastlane/Fastfile
lane :blue_green_deploy do
  # Deploy to staging (blue)
  deploy_to_staging
  
  # Run smoke tests
  run_smoke_tests
  
  # If tests pass, promote to production (green)
  if smoke_tests_passed?
    promote_to_production
  else
    rollback_deployment
  end
end

private_lane :deploy_to_staging do
  build_app(
    scheme: "MyAwesomeApp-Staging",
    configuration: "Staging"
  )
  
  upload_to_testflight(
    groups: ["Internal Testers"]
  )
end

private_lane :promote_to_production do
  build_app(
    scheme: "MyAwesomeApp",
    configuration: "Release"
  )
  
  upload_to_app_store(
    submit_for_review: true,
    automatic_release: false
  )
end
```

### 📱 Feature Flags

```swift
// Core/FeatureFlags.swift
struct FeatureFlags {
    
    @FeatureFlag("new_ui_enabled")
    static var newUIEnabled: Bool
    
    @FeatureFlag("analytics_enabled")
    static var analyticsEnabled: Bool
    
    @FeatureFlag("beta_features")
    static var betaFeatures: Bool
}

@propertyWrapper
struct FeatureFlag {
    private let key: String
    private let defaultValue: Bool
    
    init(_ key: String, defaultValue: Bool = false) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: Bool {
        return RemoteConfig.shared.bool(forKey: key, defaultValue: defaultValue)
    }
}
```

## Monitoring & Analytics

### 📊 Build Metrics

```ruby
# fastlane/Fastfile
lane :collect_metrics do
  # Build time tracking
  start_time = Time.now
  
  build_app(
    scheme: SCHEME,
    configuration: "Release"
  )
  
  build_time = Time.now - start_time
  
  # Send metrics to analytics
  send_build_metrics(
    build_time: build_time,
    success: true
  )
end

private_lane :send_build_metrics do |options|
  # Send to your analytics service
  sh "curl -X POST https://analytics.yourcompany.com/builds \
      -H 'Content-Type: application/json' \
      -d '{\"build_time\": #{options[:build_time]}, \"success\": #{options[:success]}}'"
end
```

### 🔔 Notifications

```ruby
# fastlane/Fastfile
lane :send_notifications do |options|
  # Slack notification
  slack(
    message: options[:message],
    channel: "#ios-releases",
    success: options[:success],
    payload: {
      "Build Number" => get_build_number,
      "Version" => get_version_number,
      "Branch" => git_branch
    }
  )
  
  # Email notification
  mail(
    to: "team@yourcompany.com",
    subject: "iOS Build #{options[:success] ? 'Succeeded' : 'Failed'}",
    body: options[:message]
  )
  
  # Teams notification
  teams(
    title: "iOS Build Update",
    message: options[:message],
    theme_color: options[:success] ? "good" : "danger"
  )
end
```

## Troubleshooting

### 🐛 Common Issues

#### 1. Code Signing Issues

```bash
# Fix: Update provisioning profiles
fastlane match development --readonly
fastlane match appstore --readonly

# Or use automatic signing
# Xcode > Project > Signing & Capabilities > Automatically manage signing
```

#### 2. Build Failures

```bash
# Clean build folder
xcodebuild clean -workspace MyAwesomeApp.xcworkspace -scheme MyAwesomeApp

# Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reset package cache
rm -rf .build
xcodebuild -resolvePackageDependencies
```

#### 3. Test Failures

```bash
# Run tests with verbose output
xcodebuild test \
  -workspace MyAwesomeApp.xcworkspace \
  -scheme MyAwesomeApp \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -verbose

# Check simulator status
xcrun simctl list devices
xcrun simctl boot "iPhone 15 Pro"
```

#### 4. Dependency Issues

```bash
# Reset CocoaPods
rm -rf Pods Podfile.lock
pod install

# Reset SPM
rm -rf .build Package.resolved
xcodebuild -resolvePackageDependencies

# Update dependencies
pod update  # CocoaPods
# or
xcodebuild -resolvePackageDependencies  # SPM
```

### 📋 Debug Checklist

- [ ] **Xcode Version**: Correct Xcode version selected
- [ ] **Certificates**: Valid and not expired
- [ ] **Provisioning**: Profiles up to date
- [ ] **Dependencies**: All dependencies resolved
- [ ] **Simulators**: Target simulators available
- [ ] **Disk Space**: Sufficient disk space available
- [ ] **Network**: Stable internet connection
- [ ] **Permissions**: Proper file permissions
- [ ] **Environment**: Environment variables set correctly
- [ ] **Git**: Clean working directory

### 🔧 Performance Optimization

```yaml
# Optimize CI performance
- name: Cache Dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/Library/Caches/CocoaPods
      ~/.cache/pip
      .build
    key: ${{ runner.os }}-deps-${{ hashFiles('**/Podfile.lock', '**/Package.resolved') }}

- name: Parallel Testing
  run: |
    xcodebuild test-without-building \
      -parallel-testing-enabled YES \
      -parallel-testing-worker-count 4

- name: Incremental Builds
  run: |
    xcodebuild build \
      -enableAddressSanitizer NO \
      -enableThreadSanitizer NO \
      -enableUBSanitizer NO
```

---

## 📋 CI/CD Setup Checklist

### ✅ Initial Setup

- [ ] **CI Platform**: GitHub Actions, Xcode Cloud, or Jenkins configured
- [ ] **Secrets**: All required secrets and certificates added
- [ ] **Workflows**: CI/CD workflows created and tested
- [ ] **Code Quality**: SwiftLint and SwiftFormat integrated
- [ ] **Testing**: Automated testing configured
- [ ] **Coverage**: Code coverage reporting set up
- [ ] **Notifications**: Team notifications configured

### ✅ Advanced Features

- [ ] **Parallel Testing**: Multiple devices and test plans
- [ ] **Security Scanning**: Vulnerability checks integrated
- [ ] **Performance Monitoring**: Build metrics collection
- [ ] **Feature Flags**: Remote configuration support
- [ ] **Blue-Green Deployment**: Staging and production environments
- [ ] **Rollback Strategy**: Quick rollback procedures

### ✅ Monitoring

- [ ] **Build Status**: Dashboard for build monitoring
- [ ] **Performance Metrics**: Build time and success rate tracking
- [ ] **Error Tracking**: Automated error reporting
- [ ] **Analytics**: Usage and performance analytics
- [ ] **Alerting**: Critical failure notifications

---

**Remember**: A robust CI/CD pipeline is essential for maintaining code quality and enabling rapid, reliable deployments. Start simple and gradually add more sophisticated features as your team grows! 🚀