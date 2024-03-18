#!/bin/bash
# !!! NOTE !!! This script doesn't work. I don't now the reason but doing the process manually it works. If I do it with the script sometimes it works sometime no

# Function to handle failures
function fail()
{
  declare -r C_ERROR="\033[1;31m"  
  declare -r C_NORMAL="\033[0m"   
  /usr/bin/echo -e "\n$(date +'%Y-%m-%dT%H:%M:%S%z') ${C_ERROR}[*EE] ${*}${C_NORMAL}\n" >&2  # Print error message with timestamp
  /usr/bin/echo -e "\e[1;33mReturning to MENU\e[0m"  # Inform user of return to menu
  exit 2  # Exit script with error code
}

function testing()
{
    /usr/bin/echo -e "\n++++++++++++++++++++++++ !!!WARNING!!! ++++++++++++++++++++++++\n"
    /usr/bin/echo -e "This function is in testing mode, not every time it works so run it at your own risk (it could be that you can't use sudo command anymore)\n"
    read -p "Do you want to proceed? (Y/n): " choice
    choice="${choice,,}"  # Convert user input to lowercase
    if [ "$choice" == "n" ]; then  # If user chooses not to proceed
        fail "Process terminated" 
    fi
}

# Function to install required packages
function pkg_installation() 
{
    /usr/bin/echo -e "\n++++++++++++++++++++ PACKAGES-INSTALLATION ++++++++++++++++++++\n"
    /usr/bin/echo -e "Packages needed: libpam-u2f\n"
    /usr/bin/echo "Necessary package will be installed, if you already have it the action will be skipped"
    read -p "Do you want to proceed? (Y/n): " choice  # Prompt user for confirmation
    choice="${choice,,}"  # Convert user input to lowercase
    if [ "$choice" == "n" ]; then  # If user chooses not to proceed
        fail "Process terminated" 
    fi
    # Check if libpam-u2f package is already installed
    if ! dpkg -l libpam-u2f >/dev/null 2>&1; then
        sudo apt install libpam-u2f || fail "Failed to install libpam-u2f package"  # Install required packages
        /usr/bin/echo -e "\nDone downloading libpam-u2f\n!" 
    else
        /usr/bin/echo -e "\nLibpam-u2f packages are already installed"  # Inform user that required packages are already installed
    fi
}

# Function to erase FIDO configuration
function fido_erase()
{
    /usr/bin/echo -e "\n++++++++++++++++++++++++ ERASING-FIDO +++++++++++++++++++++++++\n"
    read -p "Do you want to erase FIDO configuration? (Y/n): " choice
    choice="${choice,,}"  # Convert to lowercase
    if [ "$choice" != "n" ]; then
        /usr/bin/echo -e "\nErasing FIDO..."
        /usr/bin/ykman fido reset || fail "Failed to erase FIDO configuration" # Erasing FIDO
        /usr/bin/echo -e "\nFIDO erased successfully!"
    fi
}

# Function to change PIN
function change_pin() {
    /usr/bin/echo -e "\n+++++++++++++++++++++++++ CHANGE-PIN ++++++++++++++++++++++++++\n"
    read -p "Do you want to change PIN (default is 123456)? (Y/n): " choice
    choice="${choice,,}"  # Convert to lowercase     
    if [ "$choice" != "n" ]; then
        /usr/bin/echo
        read -s -p "Enter new PIN: " new_pin
        /usr/bin/echo
        /usr/bin/ykman fido access change-pin -n "$new_pin" || fail "Failed to change PIN." # Changing PIN
        /usr/bin/echo -e "\nPIN changed successfully!"
    fi
}

# Function to move keys from pamu2fcfg to ~/.config/Yubico dir
function move_keys() {
    /usr/bin/echo -e "\n+++++++++++++++++++++++ CONFIGURATION +++++++++++++++++++++++++\n"
    /usr/bin/echo -e "Creating Yubico dir in .config"
    mkdir -p ~/.config/Yubico || fail "Failed to create dir" # Creating ~/.config/Yubico dir
    /usr/bin/echo -e "Done! \n"
    /usr/bin/echo -e "Moving U2F Keys inside Yubico dir. It will ask you FIDO pin, then TOUCH YOUR YK\n" 
    sudo pamu2fcfg > ~/.config/Yubico/u2f_keys || fail "Failed to store u2f keys" # Moving FIDO key to ~/.config/Yubico dir
    /usr/bin/echo -e "Done! \n"
}   

# Function to modify PAM configuration in order to perform sudo command with only YK 2fa
function modify_pam() {
    /usr/bin/echo -e "Adding important lines to PAM configuration\n"
    sudo sed -i '/@include common-auth/ a\
auth       required   pam_u2f.so' /etc/pam.d/sudo || fail "Failed to add lines in PAM configuration" # Writing auth line in right place in /etc/pam.d/sudo file
    /usr/bin/echo -e "Line 1: Done! \n"
    read -p "A system reboot is needed to add configurations. Would you like to do it now? (y/n): " choice # Asking for system reboot to apply changes
    choice="${choice,,}"  # Convert to lowercase     
    if [ "$choice" != "n" ]; then
        /usr/bin/echo -e "\nRestarting system\n"
        sudo reboot
    fi
    /usr/bin/echo -e "\nDone!\n"
}

# Main script starts here

# Warning messages
testing

# Preliminary Actions
pkg_installation

# FIDO erase
fido_erase

# Change PIN
change_pin

# Create directory for Yubico config and move u2f_keys
move_keys

# Modify PAM configuration
modify_pam 

# Returning to Menu
./YK_Menu.sh



