#!/bin/bash

# Release Management Script for GH OBS Helper
# This script helps manage release notes to prevent them from growing too long

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to archive current release notes
archive_release_notes() {
    local version=$1

    print_info "Archiving release notes for version $version..."

    # Check if RELEASE_NOTES.md exists
    if [[ ! -f "RELEASE_NOTES.md" ]]; then
        print_error "RELEASE_NOTES.md not found!"
        exit 1
    fi

    # Create backup
    cp RELEASE_NOTES.md "RELEASE_NOTES_backup_$(date +%Y%m%d_%H%M%S).md"
    print_success "Created backup of current release notes"

    # Extract current release notes (everything before the first "---" or "## 🚀 GH OBS Helper Release" after the first one)
    awk '/^## 🚀 GH OBS Helper Release/ {if(count++>0) exit} 1' RELEASE_NOTES.md > temp_current.md

    # Append to archive (prepend to keep newest first)
    if [[ -f "RELEASE_NOTES_ARCHIVE.md" ]]; then
        # Get the header from archive
        head -n 3 RELEASE_NOTES_ARCHIVE.md > temp_archive.md
        echo "" >> temp_archive.md
        echo "---" >> temp_archive.md
        echo "" >> temp_archive.md

        # Add current release (skip the main header)
        tail -n +3 temp_current.md >> temp_archive.md
        echo "" >> temp_archive.md

        # Add rest of archive (skip header)
        tail -n +5 RELEASE_NOTES_ARCHIVE.md >> temp_archive.md

        mv temp_archive.md RELEASE_NOTES_ARCHIVE.md
    else
        # Create new archive file
        echo "# Release Notes Archive" > RELEASE_NOTES_ARCHIVE.md
        echo "" >> RELEASE_NOTES_ARCHIVE.md
        echo "This file contains archived release notes for older versions of GH OBS Helper." >> RELEASE_NOTES_ARCHIVE.md
        echo "" >> RELEASE_NOTES_ARCHIVE.md
        echo "---" >> RELEASE_NOTES_ARCHIVE.md
        echo "" >> RELEASE_NOTES_ARCHIVE.md
        tail -n +3 temp_current.md >> RELEASE_NOTES_ARCHIVE.md
    fi

    # Clean up
    rm -f temp_current.md

    print_success "Archived release notes for $version"
}

# Function to prepare new release notes
prepare_new_release() {
    local new_version=$1

    print_info "Preparing release notes for version $new_version..."

    # Copy template to RELEASE_NOTES.md
    if [[ -f "RELEASE_NOTES_TEMPLATE.md" ]]; then
        cp RELEASE_NOTES_TEMPLATE.md RELEASE_NOTES.md

        # Replace version placeholders
        sed -i "s/\[VERSION\]/$new_version/g" RELEASE_NOTES.md

        print_success "Created new release notes template for $new_version"
        print_info "Please edit RELEASE_NOTES.md to add your release information"
    else
        print_error "RELEASE_NOTES_TEMPLATE.md not found!"
        exit 1
    fi
}

# Function to update package.json version
update_package_version() {
    local new_version=$1

    print_info "Updating package.json version to $new_version..."

    if [[ -f "package.json" ]]; then
        # Remove 'v' prefix if present
        version_number=${new_version#v}

        # Update version in package.json
        sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$version_number\"/" package.json

        print_success "Updated package.json version to $version_number"
    else
        print_error "package.json not found!"
        exit 1
    fi
}

# Main function
main() {
    echo ""
    print_info "GH OBS Helper Release Management"
    echo "=================================="
    echo ""

    # Check if we're in the right directory
    if [[ ! -f "action.yml" ]] || [[ ! -f "package.json" ]]; then
        print_error "This script must be run from the root of the gh-obs-helper repository!"
        exit 1
    fi

    # Get current version from package.json
    current_version=$(grep '"version"' package.json | sed 's/.*"version": "\([^"]*\)".*/\1/')
    print_info "Current version: v$current_version"

    # Ask for new version
    echo ""
    read -p "Enter new version (e.g., 1.2.0): " new_version

    # Add 'v' prefix if not present
    if [[ ! $new_version =~ ^v ]]; then
        new_version="v$new_version"
    fi

    print_info "New version will be: $new_version"
    echo ""

    # Confirm
    read -p "Continue with release preparation? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        print_warning "Release preparation cancelled"
        exit 0
    fi

    echo ""

    # Archive current release notes
    archive_release_notes "v$current_version"

    # Update package.json
    update_package_version "$new_version"

    # Prepare new release notes
    prepare_new_release "$new_version"

    echo ""
    print_success "Release preparation complete!"
    echo ""
    print_info "Next steps:"
    echo "1. Edit RELEASE_NOTES.md with your release information"
    echo "2. Build the project: npm run build"
    echo "3. Commit changes: git add . && git commit -m 'Prepare release $new_version'"
    echo "4. Create and push tag: git tag $new_version && git push origin $new_version"
    echo "5. Create GitHub release using the content from RELEASE_NOTES.md"
    echo ""
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
