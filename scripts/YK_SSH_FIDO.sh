#!/bin/bash

# Function to handle failures
function fail()
{
  declare -r C_ERROR="\033[1;31m"
  declare -r C_NORMAL="\033[0m"

  /usr/bin/echo -e "\n$(date +'%Y-%m-%dT%H:%M:%S%z') ${C_ERROR}[*EE] ${*}${C_NORMAL}\n" >&2  # Print error message with timestamp
  /usr/bin/echo -e "\e[1;33mReturning to MENU\e[0m"  # Inform user of return to menu

  exit 1 # Exit script with error code
}

# Function to check the validity of the email address
function check_email() 
{
    local pattern="^[a-zA-Z0-9._%+-]+@domain\.com$"
    local email=""

    while true; do
        read -p "Please enter an email address (must belong to the "domain.com" domain): " email
        if [[ $email =~ $pattern ]]; 
        then
            /usr/bin/echo
            /usr/bin/echo "$email"   # Returning the valid email address
            break
        fi
    done
}

# Function to handle package installation
function pkg_installation() 
{
    /usr/bin/echo -e "\n++++++++++++++++++++ PACKAGES-INSTALLATION ++++++++++++++++++++\n"
    /usr/bin/echo -e "Packages needed: YubiKey-Manager\n"
    /usr/bin/echo "Necessary packages will be installed, if you already have them the action will be skipped"

    read -p "Do you want to proceed? (Y/n): " choice
    choice="${choice,,}"  # Convert to lowercase

    if [ "$choice" == "n" ]; 
    then
        fail "Process terminated"
    fi

    # Check if the packages are already installed
    if ! dpkg -l yubikey-manager >/dev/null 2>&1; 
    then
        sudo apt install yubikey-manager || fail "Failed to install required packages."
        /usr/bin/echo -e "\nDone downloading packages!"
    else
        /usr/bin/echo -e "\nRequired packages are already installed"
    fi
}

# Function to erase FIDO configuration
function erase_FIDO() 
{
    /usr/bin/echo -e "\n++++++++++++++++++++++++ ERASING-FIDO +++++++++++++++++++++++++\n"

    read -p "Do you want to erase FIDO configuration? (Y/n): " choice
    choice="${choice,,}"  # Convert to lowercase

    if [ "$choice" != "n" ]; 
    then
        /usr/bin/echo -e "\nErasing FIDO..."
        /usr/bin/ykman fido reset || fail "Failed to erase FIDO configuration"  # Resetting FIDO
        /usr/bin/echo -e "\nFIDO erased successfully!"
    fi
}

# Function to change PIN
function change_pin() 
{
    /usr/bin/echo -e "\n+++++++++++++++++++++++++ CHANGE-PIN ++++++++++++++++++++++++++\n"
    /usr/bin/echo "NOTE! Keys won't be generated if you use default PIN"

    read -p "Do you want to change PIN (default is 123456)? (Y/n): " choice
    /usr/bin/echo
    choice="${choice,,}"  # Convert to lowercase   

    if [ "$choice" != "n" ]; 
    then
        read -s -p "Enter current PIN: " current_pin
        /usr/bin/echo
        read -s -p "Enter new PIN: " new_pin
        /usr/bin/echo
        /usr/bin/ykman fido access change-pin -P "$current_pin" -n "$new_pin" || fail "Failed to change PIN."  # Changing PIN
        /usr/bin/echo -e "\nPIN changed successfully!"
    fi
}

# Function to generate keys
function create_keys() 
{
    /usr/bin/echo -e "\n++++++++++++++++++++++++ GENERATE-KEYS ++++++++++++++++++++++++\n"

    usermail=$(check_email)

    /usr/bin/echo -e "\nGenerating keys\n"

    /usr/bin/ssh-keygen -t ed25519-sk -N '' -C "$usermail" -f ~/.ssh/YK_Identity -O resident -O verify-required
    sudo chown $USER:$USER ~/.ssh/YK_Identity

    /usr/bin/echo "Keys done!"
}

function ssh_agent_handle()
{
    /usr/bin/echo -e "\n+++++++++++++++++++++++++ SHOW-PUBKEY +++++++++++++++++++++++++\n"
    /usr/bin/echo -e "This is your pubkey, paste it in the ~/.ssh/authorized_keys file on your ssh server\n"
    /usr/bin/cat ~/.ssh/YK_Identity.pub
    /usr/bin/echo -e "\nThe public key will be also stored in the file YK_Identity.pub created in  directory\n"

    read -p "When you have copied the pubkey press any enter to continue (q + enter to stop the process)" choice
    choice="${choice,,}"  # Convert to lowercase

    if [ "$choice" == "q" ]; 
    then
        /usr/bin/echo -e "\nExiting script"
        exit 0
    fi

    /usr/bin/echo -e "\n++++++++++++++++++ ADDING-PRIVKEY-TO-AGENT ++++++++++++++++++++\n"
    /usr/bin/echo -e "Restarting agent...\n"

    /usr/bin/pkill ssh-agent
    eval $(ssh-agent)
    /usr/bin/ssh-add -K || fail "Unable to add private key to interface"

    /usr/bin/echo "Done!"
}

# Function for end of the story
function end_of_the_story()
{
    /usr/bin/echo -e "\n++++++++++++++++++++++++ FINAL-ACTIONS ++++++++++++++++++++++++\n"
    /usr/bin/echo "This is your new SSH Identity:"

    /usr/bin/ssh-add -l || fail "Failed to show SSH Identity"

    /usr/bin/echo -e "\nEverything is set!\n"
    /usr/bin/echo -e "REMEMBER: every time system is rebooted or the YK is unplugged you have to add the private key to the agent with \e[1;33m/usr/bin/ssh-add -K\e[0m\n"
    /usr/bin/echo -e "When you are done with the YK SetUp script remember to restart the ssh-agent process\n"
}

# Main script starts here

# Preliminary Actions
pkg_installation || fail "Package installation failed."

# FIDO erase
erase_FIDO || fail "Ereasing PIV went wrong"

# Change PIN
change_pin || fail "PIN change failed."

# Generate keys
create_keys || fail "Failed to generate keys and certifi/usr/bin/cate."

# SSH Agent actions
ssh_agent_handle || fail "Failed to show public key."

# End of the story
end_of_the_story || fail "Failed to complete the script."

/usr/bin/echo -e "\e[1;33mReturning to MENU\e[0m"

./YK_Menu.sh
