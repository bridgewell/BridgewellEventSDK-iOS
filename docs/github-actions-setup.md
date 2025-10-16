# GitHub Actions Setup Guide

This guide explains how to set up and use the GitHub Actions workflows for automated CI/CD of the BridgewellEventSDK.

## Workflows Overview

### 1. CI Workflow (`.github/workflows/ci.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

**Jobs:**
- **Test SDK**: Runs tests on multiple iOS versions (15.0, 16.0, 17.0)
- **Lint Code**: Runs SwiftLint for code quality
- **Validate Examples**: Builds Swift and Objective-C example projects

### 2. Publish Workflow (`.github/workflows/publish.yml`)

**Triggers:**
- GitHub Release published
- Manual workflow dispatch

**Jobs:**
- **Validate SDK**: Full validation including tests
- **Publish to CocoaPods**: Publishes to CocoaPods Trunk
- **Create GitHub Release**: Creates release (for manual dispatch)
- **Notify Success**: Success notification

## Setup Instructions

### 1. Required Secrets

Add these secrets to your GitHub repository settings:

#### `COCOAPODS_TRUNK_TOKEN`
1. Get your CocoaPods Trunk token:
   ```bash
   cat ~/.netrc | grep cocoapods-trunk.herokuapp.com
   ```
2. Copy the token (after `password`)
3. Add as repository secret: `COCOAPODS_TRUNK_TOKEN`

#### `CODECOV_TOKEN` (Optional)
1. Sign up at [codecov.io](https://codecov.io)
2. Add your repository
3. Copy the token and add as repository secret: `CODECOV_TOKEN`

### 2. Publishing Process

#### Automatic Publishing (Recommended)
1. Create a new release on GitHub:
   - Go to "Releases" → "Create a new release"
   - Tag: `v0.1.0` (or your version)
   - Title: `BridgewellEventSDK v0.1.0`
   - Description: Release notes
   - Click "Publish release"

2. The workflow will automatically:
   - Validate the SDK
   - Publish to CocoaPods
   - Update documentation

#### Manual Publishing
1. Go to "Actions" → "Publish SDK"
2. Click "Run workflow"
3. Enter the version number (e.g., `0.1.0`)
4. Click "Run workflow"

### 3. Monitoring

- **CI Status**: Check the "CI" workflow for build status
- **Publishing Status**: Check the "Publish SDK" workflow for publishing status
- **CocoaPods**: Check https://cocoapods.org/pods/BridgewellEventSDK

## Workflow Features

### CI Workflow
- ✅ Multi-version iOS testing (15.0, 16.0, 17.0)
- ✅ Swift Package Manager validation
- ✅ CocoaPods podspec validation
- ✅ SwiftLint code quality checks
- ✅ Example project validation
- ✅ Code coverage reporting

### Publish Workflow
- ✅ Comprehensive validation before publishing
- ✅ Automatic version management
- ✅ CocoaPods Trunk publishing
- ✅ GitHub release creation
- ✅ Success notifications

## Troubleshooting

### Common Issues

1. **CocoaPods Token Invalid**
   - Regenerate token: `pod trunk register your-email@example.com`
   - Update the `COCOAPODS_TRUNK_TOKEN` secret

2. **Xcode Version Issues**
   - Update Xcode version in workflow files if needed
   - Check available versions on GitHub Actions

3. **Test Failures**
   - Check the CI workflow logs
   - Fix any failing tests before publishing

### Manual Fallback

If automated publishing fails, you can still publish manually:

```bash
# Validate
pod spec lint BridgewellEventSDK.podspec --allow-warnings

# Publish
pod trunk push BridgewellEventSDK.podspec --allow-warnings
```

## Workflow Status Badges

Add these to your main README.md:

```markdown
[![CI](https://github.com/bridgewell/BridgewellEventSDK-iOS/workflows/CI/badge.svg)](https://github.com/bridgewell/BridgewellEventSDK-iOS/actions/workflows/ci.yml)
[![Publish](https://github.com/bridgewell/BridgewellEventSDK-iOS/workflows/Publish%20SDK/badge.svg)](https://github.com/bridgewell/BridgewellEventSDK-iOS/actions/workflows/publish.yml)
```

## Next Steps

1. **Add the GitHub secret** (`COCOAPODS_TRUNK_TOKEN`)
2. **Create your first release** to trigger automatic publishing
3. **Monitor the workflow** in the Actions tab

For future versions:
1. Update version in `BridgewellEventSDK.podspec`
2. Update `CHANGELOG.md`
3. Create a new GitHub release
4. ✨ **Automatic publishing!**
