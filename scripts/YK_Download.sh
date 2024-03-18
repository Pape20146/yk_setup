#!/bin/bash

# Function to handle failures
function fail()
{
  declare -r C_ERROR="\033[1;31m"
  declare -r C_NORMAL="\033[0m"
  /usr/bin/echo -e "\n$(date +'%Y-%m-%dT%H:%M:%S%z') ${C_ERROR}[*EE] ${*}${C_NORMAL}\n" >&2  # Print error message with timestamp
  /usr/bin/echo -e "\e[1;33mReturning to MENU\e[0m"  # Inform user of return to menu
  exit 2  # Exit script with error code
}

function are_packages_installed()
{
    packages=("$@")

    if [ $packages == "" ]; then
        return 0
    fi 
    
    if dpkg -l ${packages[@]} >/dev/null 2>&1; then
        /usr/bin/echo -e "\n${packages[@]} packages are already installed"
        return 1
    fi

    return 0
}

# Function to install required packages
function pkg_installation() 
{
    /usr/bin/echo -e "\n++++++++++++++++++++ PACKAGES-INSTALLATION ++++++++++++++++++++\n"
    /usr/bin/echo -e "Packages needed: OpenSC, YubiKey-Manager, libpam-u2f\n" 
    /usr/bin/echo "Necessary packages will be installed, if you already have them the action will be skipped"
    read -p "Do you want to proceed? (Y/n): " choice            
    choice="${choice,,}"                                        # Convert user input to lowercase 

    if [ "$choice" == "n" ]; then
        fail "Process terminated" 
    fi

    # Check if ykman and opensc packages are already installed. Add the repo and install them if not
    packages=("opensc" "yubikey-manager")
    if ! are_packages_installed ${packages[@]}; then
        sudo apt-add-repository ppa:yubico/stable || fail "Failed to add Yubico repository"
        sudo apt update || fail "Failed to update package list"
        sudo apt install ${packages[@]} || fail "Failed to install ${packages[@]} packages"
        /usr/bin/echo -e "\nDone downloading ${packages[@]}!\n" 
    fi

    # Check if libpam-u2f package is already installed
    packages=("libpam-u2f")
    if ! are_packages_installed ${packages[@]}; then
        sudo apt install ${packages[@]} || fail "Failed to install ${packages[@]} packages"
        /usr/bin/echo -e "\nDone downloading ${packages[@]}!\n" 
    fi
}

# Main script starts here

# Call pkg_installation function
pkg_installation

# Start the YK_Menu script
./YK_Menu.sh
