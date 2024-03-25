#!/bin/bash

# Function to handle failures
function fail()
{
  declare -r C_ERROR="\033[1;31m"
  declare -r C_NORMAL="\033[0m"

  echo -e "\n$(date +'%Y-%m-%dT%H:%M:%S%z') ${C_ERROR}[*EE] ${*}${C_NORMAL}\n" >&2 # Print error message with timestamp

  exit # Exit script with error code
}

# Function to check YubiKey detection
function yk_detection() 
{
    echo -e "\n++++++++++++++++++++++ YUBIKEY-DETECTION ++++++++++++++++++++++\n"

    yk_info=$(ykman info) # Storing YK datas

    if [[ "$yk_info" == "" ]]; 
    then
        fail "No YubiKey detected; plug your YubiKey and run the script again"
    fi

    echo -e "YubiKey detected. Here are the details:\n"
    echo "$yk_info"  # Show YK datas
}

function ssh_choice()
{
    echo -e "\n+++++++++++++++++++++++++++++ SSH +++++++++++++++++++++++++++++\n\nChoose the action you want to perform:\n\n0) FIDO2 (ECC)\n1) PIV (RSA)\n2) Exit\n"
    local choice

    while true; do

        # Prompt user for input
        read -p "Write the corresponding number here (0/1/2): " choice
        choice="${choice,,}"  # Convert to lowercase
        
        # Process user input
        case $choice in
            0) ./scripts/YK_SSH_FIDO.sh   || ./YK_Menu.sh ; break ;;
            1) ./scripts/YK_SSH_PIV.sh    || ./YK_Menu.sh ; break ;;
            2) echo -e "\n\e[1;33mReturning to Menu\e[0m\n"; break ;;
            *) echo -e "\n\e[1;31mNot a valid number!\e[0m\n";;
        esac
    done
}

# Function to display the menu and handle user input
function start_of_the_story()
{
    echo -e "\n++++++++++++++++++++++++++++ MENU +++++++++++++++++++++++++++++\n\nWelcome to YubiKey Auto-SetUp (a lot better than ykman)\n\nChoose the action you want to perform:\n\n0) Download necessary packages\n1) First SetUp - Config Interfaces\n2) Use sudo command with YK 2fa (testing)\n3) SetUp SSH Keys\n4) Write useful YK functions in ~/.bashrc\n5) Exit\n"    
    local choice
    
    while true; do

        # Prompt user for input
        read -p "Write the corresponding number here (0/1/2/3/4/5): " choice
        choice="${choice,,}"  # Convert to lowercase
        
        # Process user input
        case $choice in
            0) ./scripts/YK_Download.sh   || ./YK_Menu.sh ; break ;;
            1) ./scripts/YK_Config.sh     || ./YK_Menu.sh ; break ;;
            2) ./scripts/YK_Sudo.sh       || ./YK_Menu.sh ; break ;;
            3) ssh_choice                 || ./YK_Menu.sh ; break ;;
            4) ./scripts/YK_Functions.sh  || ./YK_Menu.sh ; break ;;
            5) echo -e "\nBye-bye!\n"; exit ;;                   # Exit the program with style
            *) echo -e "\n\e[1;31mNot a valid number!\e[0m\n";;  # Inform user of invalid input and loop back to prompt again
        esac
    done
}

# Main script starts here

# Check YubiKey detection
yk_detection

# Call the function to start the menu
start_of_the_story
