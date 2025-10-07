#!/bin/bash

# BridgewellEventSDK XCFramework Build Script
# This script builds a universal XCFramework for iOS device and simulator

set -e

# Configuration
PROJECT_NAME="BridgewellEventSDK"
SCHEME_NAME="BridgewellEventSDK"
PROJECT_PATH="BridgewellEventSDK/BridgewellEventSDK.xcodeproj"
FRAMEWORK_NAME="BridgewellEventSDK"

# Build directories
BUILD_DIR="build"
DIST_DIR="dist"
ARCHIVES_DIR="${BUILD_DIR}/archives"

# Archive paths
IOS_ARCHIVE="${ARCHIVES_DIR}/iOS.xcarchive"
IOS_SIMULATOR_ARCHIVE="${ARCHIVES_DIR}/iOSSimulator.xcarchive"

# XCFramework output
XCFRAMEWORK_PATH="${DIST_DIR}/${FRAMEWORK_NAME}.xcframework"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to clean build directories
clean_build_dirs() {
    log_info "Cleaning build directories..."
    rm -rf "${BUILD_DIR}"
    rm -rf "${DIST_DIR}"
    mkdir -p "${ARCHIVES_DIR}"
    mkdir -p "${DIST_DIR}"
}

# Function to build iOS archive
build_ios_archive() {
    log_info "Building iOS archive..."
    xcodebuild archive \
        -project "${PROJECT_PATH}" \
        -scheme "${SCHEME_NAME}" \
        -destination "generic/platform=iOS" \
        -archivePath "${IOS_ARCHIVE}" \
        -configuration Release \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        ENABLE_BITCODE=NO
    
    if [ $? -eq 0 ]; then
        log_success "iOS archive built successfully"
    else
        log_error "Failed to build iOS archive"
        exit 1
    fi
}

# Function to build iOS Simulator archive
build_ios_simulator_archive() {
    log_info "Building iOS Simulator archive..."
    xcodebuild archive \
        -project "${PROJECT_PATH}" \
        -scheme "${SCHEME_NAME}" \
        -destination "generic/platform=iOS Simulator" \
        -archivePath "${IOS_SIMULATOR_ARCHIVE}" \
        -configuration Release \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        ENABLE_BITCODE=NO
    
    if [ $? -eq 0 ]; then
        log_success "iOS Simulator archive built successfully"
    else
        log_error "Failed to build iOS Simulator archive"
        exit 1
    fi
}

# Function to create XCFramework
create_xcframework() {
    log_info "Creating XCFramework..."
    
    # Remove existing XCFramework if it exists
    if [ -d "${XCFRAMEWORK_PATH}" ]; then
        rm -rf "${XCFRAMEWORK_PATH}"
    fi
    
    xcodebuild -create-xcframework \
        -framework "${IOS_ARCHIVE}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
        -framework "${IOS_SIMULATOR_ARCHIVE}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
        -output "${XCFRAMEWORK_PATH}"
    
    if [ $? -eq 0 ]; then
        log_success "XCFramework created successfully at ${XCFRAMEWORK_PATH}"
    else
        log_error "Failed to create XCFramework"
        exit 1
    fi
}

# Function to verify XCFramework
verify_xcframework() {
    log_info "Verifying XCFramework..."
    
    if [ -d "${XCFRAMEWORK_PATH}" ]; then
        log_info "XCFramework structure:"
        find "${XCFRAMEWORK_PATH}" -type d -name "*.framework" | while read framework; do
            echo "  📱 $(basename $(dirname $framework))"
        done
        
        # Check Info.plist
        if [ -f "${XCFRAMEWORK_PATH}/Info.plist" ]; then
            log_success "Info.plist found"
        else
            log_warning "Info.plist not found"
        fi
        
        # Get file size
        size=$(du -sh "${XCFRAMEWORK_PATH}" | cut -f1)
        log_info "XCFramework size: ${size}"
        
    else
        log_error "XCFramework not found at ${XCFRAMEWORK_PATH}"
        exit 1
    fi
}

# Function to create checksum
create_checksum() {
    log_info "Creating checksum..."
    
    # Create zip for distribution
    cd "${DIST_DIR}"
    zip -r "${FRAMEWORK_NAME}.xcframework.zip" "${FRAMEWORK_NAME}.xcframework"
    
    # Calculate checksum
    checksum=$(swift package compute-checksum "${FRAMEWORK_NAME}.xcframework.zip" 2>/dev/null || shasum -a 256 "${FRAMEWORK_NAME}.xcframework.zip" | cut -d' ' -f1)
    
    echo "${checksum}" > "${FRAMEWORK_NAME}.xcframework.checksum"
    
    log_success "Checksum: ${checksum}"
    log_info "Checksum saved to ${FRAMEWORK_NAME}.xcframework.checksum"
    log_info "Distribution zip created: ${FRAMEWORK_NAME}.xcframework.zip"
    
    cd - > /dev/null
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --clean     Clean build directories before building"
    echo "  -v, --verify    Only verify existing XCFramework"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              Build XCFramework"
    echo "  $0 --clean      Clean and build XCFramework"
    echo "  $0 --verify     Verify existing XCFramework"
}

# Main execution
main() {
    local clean_build=false
    local verify_only=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--clean)
                clean_build=true
                shift
                ;;
            -v|--verify)
                verify_only=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    log_info "🚀 Starting BridgewellEventSDK XCFramework build process..."
    
    # Verify project exists
    if [ ! -d "${PROJECT_PATH}" ]; then
        log_error "Project not found at ${PROJECT_PATH}"
        log_info "Current directory: $(pwd)"
        log_info "Available projects:"
        find . -name "*.xcodeproj" -type d | head -5
        exit 1
    fi
    
    if [ "$verify_only" = true ]; then
        verify_xcframework
        exit 0
    fi
    
    if [ "$clean_build" = true ]; then
        clean_build_dirs
    else
        mkdir -p "${ARCHIVES_DIR}"
        mkdir -p "${DIST_DIR}"
    fi
    
    # Build process
    build_ios_archive
    build_ios_simulator_archive
    create_xcframework
    verify_xcframework
    create_checksum
    
    log_success "🎉 XCFramework build completed successfully!"
    echo ""
    log_info "📦 Output files:"
    log_info "   XCFramework: ${XCFRAMEWORK_PATH}"
    log_info "   Distribution: ${DIST_DIR}/${FRAMEWORK_NAME}.xcframework.zip"
    log_info "   Checksum: ${DIST_DIR}/${FRAMEWORK_NAME}.xcframework.checksum"
}

# Run main function with all arguments
main "$@"
