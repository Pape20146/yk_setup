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

# Function to handle package installation
function pkg_installation() 
{
    /usr/bin/echo -e "\n++++++++++++++++++++ PACKAGES-INSTALLATION ++++++++++++++++++++\n"
    /usr/bin/echo -e "Packages needed: OpenSC, YubiKey-Manager\n"
    /usr/bin/echo "Necessary packages will be installed, if you already have them the action will be skipped"

    read -p "Do you want to proceed? (Y/n): " choice
    choice="${choice,,}"  # Convert to lowercase

    if [ "$choice" == "n" ]; 
    then
        fail "Process terminated"
    fi
    
    # Check if the packages are already installed
    if ! dpkg -l opensc yubikey-manager >/dev/null 2>&1; 
    then
        sudo apt-add-repository ppa:yubico/stable || fail "Failed to add Yubico repository."
        sudo apt update || fail "Failed to update package list."
        sudo apt install opensc yubikey-manager || fail "Failed to install required packages."
        /usr/bin/echo -e "\nDone downloading packages!"
    else
        /usr/bin/echo -e "\nRequired packages are already installed"
    fi

}

# Function to check YubiKey detection
function yk_detection() 
{
    /usr/bin/echo -e "\n++++++++++++++++++++++ YUBIKEY-DETECTION ++++++++++++++++++++++\n"

    yk_info=$(ykman info)

    if [[ "$yk_info" == "" ]]; then
        /usr/bin/echo
        fail "No YubiKey detected; plug your YubiKey and run the script again"
    fi

    /usr/bin/echo "YubiKey detected!"
}

# Function to erase PIV configuration
function erase_PIV() 
{
    /usr/bin/echo -e "\n+++++++++++++++++++++++++ ERASING-PIV +++++++++++++++++++++++++\n"

    read -p "Do you want to erase PIV configuration? (Y/n): " choice
    choice="${choice,,}"  # Convert to lowercase

    if [ "$choice" != "n" ]; 
    then
        /usr/bin/echo -e "\nErasing PIV..."
        ykman piv reset -f || fail "Failed to erase PIV configuration"  # Resetting PIV
        /usr/bin/echo -e "\nPIV erased successfully!"
    fi
}

# Function to change PIN
function change_pin() 
{
    /usr/bin/echo -e "\n+++++++++++++++++++++++++ CHANGE-PIN ++++++++++++++++++++++++++\n"

    read -p "Do you want to change PIN (default is 123456)? (Y/n): " choice
    choice="${choice,,}"  # Convert to lowercase 

    if [ "$choice" != "n" ]; 
    then
        read -s -p "Enter current PIN: " current_pin
        /usr/bin/echo
        read -s -p "Enter new PIN: " new_pin
        /usr/bin/echo
        ykman piv access change-pin -P "$current_pin" -n "$new_pin" || fail "Failed to change PIN."  # Changing PIN
        /usr/bin/echo -e "\nPIN changed successfully!"
    fi
}

# Function to generate keys and certificate
function create_keys_and_certificate() 
{
    /usr/bin/echo -e "\n+++++++++++++++++ CREATE-KEYS-&-CERTIFICATES ++++++++++++++++++\n"
    /usr/bin/echo -e "Generating keys and their certificate\n"

    sudo ykman piv keys generate -a RSA2048 --pin-policy always --touch-policy always 9a pubkey.pem || fail "Failed to generate keys."  # Generating SSH Keys and storing the private on YK (PIV slot 9a)
    sudo chown $USER:$USER pubkey.pem

    /usr/bin/echo "Keys done!"

    sudo ykman piv certificates generate -s "SSH key" 9a pubkey.pem || fail "Failed to generate certificate."  # Generating Certificate for Keys

    /usr/bin/echo "Certificate done!"
    /usr/bin/echo -e "\nKeys and certificate created successfully!"
}

# Function to show public key
function show_pubkey() 
{
    /usr/bin/echo -e "\n+++++++++++++++++++++++++ SHOW-PUBKEY +++++++++++++++++++++++++\n"

    PKCS11PATH=$(sudo find /usr/lib -name "opensc-pkcs11.so" 2> /dev/null | head -n 1) || fail "Failed to find PKCS11 library."  # Finding PKCS11 path

    /usr/bin/echo -e "This is your pubkey, paste it in the ~/.ssh/authorized_keys file on your ssh server\n"

    /usr/bin/ssh-keygen -D "$PKCS11PATH" | cut -d " " -f1,2 || fail "Failed to show public key"  # Showing pubkey

    /usr/bin/echo -e "\nThe public key will be also stored in the file pubkey.pem created in this directory\n"

    read -p "When you have copied the pubkey press any enter to continue (q + enter to stop the process)" choice
    choice="${choice,,}"  # Convert to lowercase

    if [ "$choice" == "q" ]; 
    then
        /usr/bin/echo -e "\nExiting script"
        exit 0
    fi
}

# Function to add private key to SSH Agent
function add_private_key() 
{
    /usr/bin/echo -e "\n++++++++++++++++++ ADDING-PRIVKEY-TO-AGENT ++++++++++++++++++++\n"

    PKCS11PATH=$(find /usr/lib -name "opensc-pkcs11.so" 2> /dev/null | head -n 1) || fail "Failed to find PKCS11 library."  # Finding PKCS11 path

    /usr/bin/echo "Restarting SSH Agent"

    read -p "All your ssh identities will be erased. Do you want to proceed? (Y/n): " choice
    choice="${choice,,}"  # Convert to lowercase

    if [ "$choice" == "n" ]; 
    then
        /usr/bin/echo -e "\nExiting script\n"
        exit 0
    fi

    /usr/bin/pkill ssh-agent  #Killing SSH Agent process
    eval $(ssh-agent)  #Starting SSH Agent process

    /usr/bin/echo -e "\nAdding private key to SSH agent\n"
    /usr/bin/echo -e "NOTE: PKCS#11 password is your PIV PIN\n"

    /usr/bin/ssh-add -s "$PKCS11PATH" || fail "Failed to add private key to SSH agent."  # Adding private key to SSH agent

    /usr/bin/echo -e "\nPrivate key added successfully to the ssh-agent!"
}

# Function to create ykjoin function in ~/.bashrc
function create_bashrc_function() 
{
    /usr/bin/echo -e "\n++++++++++++++++++ CREATING-BASHRC-FUNCTION +++++++++++++++++++\n"

    # Check if ykjoin function already exists in ~/.bashrc
    if grep -q "function ykjoin()" ~/.bashrc; 
    then
        source ~/.bashrc || fail "Unable to update bashrc file"
        /usr/bin/echo -e "\nykjoin function already exists in ~/.bashrc\n"
    else
        /usr/bin/echo -e "Now will be created the function 'ykjoin' in your ~/.bashrc file\n"

        # Above there is ykjoin function
        /usr/bin/echo -e "\n# Function to restart SSH Agent and add YubiKey interface" >> ~/.bashrc || fail "Unable to modify ~/.bashrc file"
        /usr/bin/echo "function ykjoin() {" >> ~/.bashrc
        /usr/bin/echo "    PKCS11PATH=\$(find /usr/lib -name 'opensc-pkcs11.so' | head -n 1)" >> ~/.bashrc
        /usr/bin/echo "    /usr/bin/echo -e '\nRestarting SSH Agent\n'" >> ~/.bashrc
        /usr/bin/echo "    /usr/bin/pkill ssh-agent" >> ~/.bashrc
        /usr/bin/echo "    eval \$(ssh-agent)" >> ~/.bashrc
        /usr/bin/echo "    /usr/bin/echo" >> ~/.bashrc
        /usr/bin/echo "    /usr/bin/ssh-add -s "\$PKCS11PATH"" >> ~/.bashrc
        /usr/bin/echo "    /usr/bin/echo -e '\nThis is your identity:\n'" >> ~/.bashrc
        /usr/bin/echo "    /usr/bin/ssh-add -l" >> ~/.bashrc
        /usr/bin/echo "}" >> ~/.bashrc

        source ~/.bashrc || fail "Unable to update bashrc file" # Refreshing bashrc configuration
        /usr/bin/echo "ykjoin function has been added to ~/.bashrc successfully"
    fi
}

# Function for end of the story
function end_of_the_story() 
{
    /usr/bin/echo -e "\n++++++++++++++++++++++++ FINAL-ACTIONS ++++++++++++++++++++++++\n"

    /usr/bin/echo "This is your new SSH Identity:"
    /usr/bin/ssh-add -l || fail "Failed to show SSH Identity"

    /usr/bin/echo -e "\nEverything is set!\n"
    /usr/bin/echo "REMEMBER: every time system is rebooted you have to restart SSH agent and add the private key to it."
    /usr/bin/echo -e "\nWhen the script ends remember to type \e[1;33msource ~/.bashrc\e[0m and run \e[1;33mykjoin\e[0m to complete the process"
}

# Main script starts here

# Preliminary Actions
pkg_installation || fail "Package installation failed."

# Check YubiKey detection
yk_detection || fail "YubiKey detection failed."

# PIV erase
erase_PIV || fail "Ereasing PIV went wrong"

# Change PIN
change_pin || fail "PIN change failed."

# Generate keys and certificate
create_keys_and_certificate || fail "Failed to generate keys and certificate."

# Show public key
show_pubkey || fail "Failed to show public key."

# Add private key to SSH Agent
add_private_key || fail "Failed to add private key to SSH Agent."

# Create function in bashrc file
create_bashrc_function || fail "Failed to create function in bashrc file"

# End of the story
end_of_the_story || fail "Failed to complete the script."

/usr/bin/echo -e "\e[1;33mReturning to MENU\e[0m"

./YK_Menu.sh
