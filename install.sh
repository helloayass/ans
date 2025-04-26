#!/bin/bash

# Blueprint Installation Script
# Based on https://blueprint.zip/docs/?page=getting-started/Installation

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print info messages
print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Function to check if a command was successful
check_success() {
    if [ $? -eq 0 ]; then
        print_success "$1"
    else
        echo -e "${RED}✗ Error: $1 failed${NC}"
        exit 1
    fi
}

# Display welcome message
clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}║      Blueprint Installer for Pterodactyl                   ║${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
print_info "This script will install Blueprint on your Pterodactyl panel."
print_info "Make sure you're running this script as a user with sudo privileges."
print_info "Press ENTER to continue or CTRL+C to cancel..."
read

# Get Pterodactyl directory
print_header "Pterodactyl Path"
read -p "Enter your Pterodactyl directory path [/var/www/pterodactyl]: " PTERODACTYL_PATH
PTERODACTYL_PATH=${PTERODACTYL_PATH:-/var/www/pterodactyl}

if [ ! -d "$PTERODACTYL_PATH" ]; then
    echo -e "${RED}Error: The directory $PTERODACTYL_PATH does not exist.${NC}"
    exit 1
fi

print_info "Using Pterodactyl directory: $PTERODACTYL_PATH"

# Prepare for liftoff: Install Node.js v20
print_header "Installing Node.js v20"
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update
sudo apt-get install -y nodejs
check_success "Node.js installation"

# Install Yarn
print_header "Installing Yarn"
sudo npm i -g yarn
check_success "Yarn installation"

# Initialize dependencies
print_header "Initializing dependencies"
cd "$PTERODACTYL_PATH"
yarn
check_success "Dependency initialization"

# Install additional dependencies
print_header "Installing additional dependencies"
sudo apt-get install -y zip unzip git curl wget
check_success "Additional dependencies installation"

# Download the latest release
print_header "Downloading Blueprint"
LATEST_RELEASE_URL=$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)
wget "$LATEST_RELEASE_URL" -O release.zip
check_success "Blueprint download"

# Extract release
print_header "Extracting Blueprint"
unzip -o release.zip
check_success "Blueprint extraction"

# Configuration
print_header "Configuring Blueprint"
touch .blueprintrc
echo 'WEBUSER="www-data";
OWNERSHIP="www-data:www-data";
USERSHELL="/bin/bash";' > .blueprintrc
check_success "Blueprint configuration"

# Let Blueprint do the rest
print_header "Finalizing Blueprint installation"
chmod +x blueprint.sh
bash blueprint.sh
check_success "Blueprint installation"

# Enable Bash autocompletion (optional)
print_header "Setting up Bash autocompletion"
if [ -f ~/.bashrc ]; then
    if ! grep -q "source blueprint;" ~/.bashrc; then
        echo 'source blueprint;' >> ~/.bashrc
        print_success "Bash autocompletion enabled"
    else
        print_info "Bash autocompletion already enabled"
    fi
else
    print_info "Skipping Bash autocompletion setup (~/.bashrc not found)"
fi

# Cleanup
print_header "Cleaning up"
rm release.zip
check_success "Cleanup"

# Display success message
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                            ║${NC}"
echo -e "${GREEN}║      Blueprint installation complete!                      ║${NC}"
echo -e "${GREEN}║                                                            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
print_info "To learn more about Blueprint's command line utility, run:"
echo -e "  ${YELLOW}blueprint -help${NC}"
print_info "Visit the extension development guide:"
echo -e "  ${YELLOW}https://blueprint.zip/docs/?page=getting-started/Extension-development${NC}"
print_info "Find new extensions at:"
echo -e "  ${YELLOW}https://blueprint.zip/browse${NC}"
echo ""
print_info "If you like the project, consider starring it on GitHub:"
echo -e "  ${YELLOW}https://github.com/BlueprintFramework/framework${NC}"
echo ""
