#!/bin/bash

# Function to handle failures
function fail()
{
  declare -r C_ERROR="\033[1;31m"
  declare -r C_NORMAL="\033[0m"
  /usr/bin/echo -e "\n$(date +'%Y-%m-%dT%H:%M:%S%z') ${C_ERROR}[*EE] ${*}${C_NORMAL}\n" >&2  # Print error message with timestamp
  /usr/bin/echo -e "\e[1;33mReturning to MENU\e[0m"  # Inform user of return to menu
  exit 2 # Exit script with error code
}

function start()
{
    /usr/bin/echo -e "\n++++++++++++++++++++++++++ FUNCTIONS ++++++++++++++++++++++++++\n\nChoose the action you want to perform:\n\n0) Have a list of the functions\n1) Write functions\n2) Exit\n"
    local choice
    while true; do

        read -p "Write the corresponding number here (0/1/2): " choice
        choice="${choice,,}"  # Convert to lowercase

        case $choice in
            0) list || ../YK_Functions.sh ; start; break ;; # Call list() script
            1) create_bashrc_function || ../YK_Functions.sh ; start; break ;;  # Call create_bashrc_function() script
            2) /usr/bin/echo -e "\n\e[1;33mReturning to Menu\e[0m\n"; break ;;  # Exit and return to menu
            *) /usr/bin/echo -e "\n\e[1;31mNot a valid number!\e[0m\n";;  # Inform user of invalid input and loop back to prompt again
        esac
    done
}

# Function to return the functions list
function list()
{
    /usr/bin/echo -e "\nAvailable functions:\n"
    /usr/bin/echo -e "1. ykjoin - Restart SSH Agent and add YubiKey interface\n"
    /usr/bin/echo -e "2. ykmenu - Run YubiKey configuration menu directly\n"
}


# Function to create ykjoin function in ~/.bashrc
function create_bashrc_function() {
    /usr/bin/echo -e "\n++++++++++++++++++ CREATING-BASHRC-FUNCTION +++++++++++++++++++\n"
    # Check if ykjoin function already exists in ~/.bashrc
    if grep -q "function ykjoin()" ~/.bashrc; then
        source ~/.bashrc || fail "Unable to update bashrc file"
        /usr/bin/echo -e "\nykjoin function already exists in ~/.bashrc\n"
    else
        /usr/bin/echo -e "Now will be created the function 'ykjoin' in your ~/.bashrc file\n"

        # ykjoin function
        cat functions/.ykjoin.sh >> ~/.bashrc

        source ~/.bashrc || fail "Unable to update bashrc file"  # Refreshing bashrc configuration
        /usr/bin/echo "ykjoin function has been added to ~/.bashrc successfully"
    fi
    if grep -q "function ykmenu()" ~/.bashrc; then
        source ~/.bashrc || fail "Unable to update bashrc file"
        /usr/bin/echo -e "\nykmenu function already exists in ~/.bashrc\n"
    else
        /usr/bin/echo -e "Now will be created the function 'ykmenu' in your ~/.bashrc file\n"

        # ykmenu function
        cat functions/.ykmenu.sh >> ~/.bashrc

        source ~/.bashrc || fail "Unable to update bashrc file"  # Refreshing bashrc configuration
        /usr/bin/echo "ykmenu function has been added to ~/.bashrc successfully"
    fi
    /usr/bin/echo -e "\nWhen the script ends remember to type \e[1;33msource ~/.bashrc\e[0m to complete the process"
}

# Main script starts here

# Call the start function to begin the script
start

./YK_Menu.sh  # Start the YK_Menu script