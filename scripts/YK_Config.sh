#!/bin/bash

# Function to handle failures
function fail()
{
  declare -r C_ERROR="\033[1;31m"   # Define red color for error messages
  declare -r C_NORMAL="\033[0m"      # Define normal color

  /usr/bin/echo  -e "\n$(date +'%Y-%m-%dT%H:%M:%S%z') ${C_ERROR}[*EE] ${*}${C_NORMAL}\n" >&2  # Print error message in red
  /usr/bin/echo  -e "\e[1;33mReturning to Interfaces\e[0m"  # Inform about returning to Interfaces

  exit 1  # Exit with error code 1
}

# Function for FIDO interface
function fido()
{
    local choice
    while true; do
        /usr/bin/echo  -e "\n++++++++++++++++++++++++++++ FIDO +++++++++++++++++++++++++++++\n\nChoose which action you want to perform:\n\n0) Complete SetUp\n1) Erase interface\n2) Options\n3) Return to Interfaces\n"

        read -p "Write the corresponding number here (0/1/2/3): " choice
        choice="${choice,,}"  # Convert to lowercase

        case $choice in
            0)
                /usr/bin/echo 
                read -s -p "Enter new PIN: " new_pin
                /usr/bin/echo 
                /usr/bin/ykman fido access change-pin -n "$new_pin" || fail "Failed to change PIN."  # Change PIN
                /usr/bin/echo  -e "\nPIN changed successfully!";;
            1)
                /usr/bin/echo 
                read -p "Are you sure to erase current FIDO configuration? (Y/n): " choice
                choice="${choice,,}"  # Convert to lowercase

                if [ "$choice" != "n" ]; then
                    /usr/bin/echo  -e "\nErasing FIDO..."
                    /usr/bin/ykman fido reset || fail "Failed to erase FIDO configuration"  # Reset FIDO
                    /usr/bin/echo  -e "\nFIDO erased successfully!"
                fi;;
            2)
                local choice
                while true; do
                    /usr/bin/echo  -e "\n\nChoose option:\n\n0) Change PIN\n1) Request user authentication every time (not every YK allows it)\n2) Set minimum PIN lenght (not every YK allows it)\n3) Return to FIDO Interface\n"

                    read -p "Write the corresponding number here (0/1/2/3): " choice
                    choice="${choice,,}"  # Convert to lowercase

                    case $choice in
                        0)
                            /usr/bin/echo 
                            read -s -p "Enter current PIN: " current_pin
                            /usr/bin/echo 
                            read -s -p "Enter new PIN: " new_pin
                            /usr/bin/echo 
                            /usr/bin/ykman piv access change-pin -P "$current_pin" -n "$new_pin" || fail "Failed to change PIN."  # Change PIN
                            /usr/bin/echo  -e "\nPIN changed successfully!";;
                        1)
                            /usr/bin/echo  -e "\nSetting user authentication to Always (not every YK allows it)\n"
                            /usr/bin/ykman fido config toggle-always-up || fail "Unable to set the configuration"  # Setting user authentication to Always
                            /usr/bin/echo  -e "\nConfiguration set successfully";;
                        2)
                            /usr/bin/echo 
                            read -s -p "Set minimum PIN lenght: " choice
                            /usr/bin/echo 
                            /usr/bin/ykman fido access set-min-lenght "$choice"|| fail "Unable to set the configuration"  # Setting minimum PIN lenght
                            /usr/bin/echo  -e "\nConfiguration set successfully";;

                        3) /usr/bin/echo  -e "\n\e[1;33mReturning to FIDO\e[0m"; break;;  # Exit and return to Interfaces menu

                        *) /usr/bin/echo  -e "\n\e[1;31mNot a valid number!\e[0m\n";; # Inform about invalid input
                    esac
                done
                ;;
            3) /usr/bin/echo  -e "\n\e[1;33mReturning to Interfaces\e[0m";break;;  # Return to menu
            *) /usr/bin/echo  -e "\n\e[1;31mNot a valid number!\e[0m\n";;  # Inform about invalid input
        esac
    done
}

# Function for PIV interface
function piv()
{
    local choice
    while true; do
        /usr/bin/echo  -e "\n+++++++++++++++++++++++++++++ PIV +++++++++++++++++++++++++++++\n\nChoose which action you want to perform:\n\n0) Complete SetUp\n1) Erase interface\n2) Change PIN\n3) Return to Interfaces\n"

        read -p "Write the corresponding number here (0/1/2/3): " choice
        choice="${choice,,}"  # Convert to lowercase

        case $choice in
            0)
                /usr/bin/echo 
                read -s -p "Enter new PIN: " new_pin
                /usr/bin/echo 
                /usr/bin/ykman piv access change-pin -n "$new_pin" || fail "Failed to change PIN."  # Change PIN
                /usr/bin/echo  -e "\nPIN changed successfully!"
                /usr/bin/echo 
                read -s -p "Enter new PUK: " new_puk
                /usr/bin/echo 
                /usr/bin/ykman piv access change-puk -n "$new_puk" || fail "Failed to change PUK."  # Change PUK
                /usr/bin/echo  -e "\nPUK changed successfully!"
                /usr/bin/echo 
                read -s -p "Would you like to generate a new management key? (Y/n):" choice
                choice="${choice,,}"  # Convert to lowercase
                if [ "$choice" != "n" ]; then
                    /usr/bin/echo 
                    /usr/bin/ykman piv access change-management-key -g  # Generate Management Key
                    /usr/bin/echo 
                fi;;
            1)
                /usr/bin/echo 
                read -p "Are you sure to erase current PIV configuration? (Y/n): " choice
                choice="${choice,,}"  # Convert to lowercase
                if [ "$choice" != "n" ]; then
                    /usr/bin/echo  -e "\nErasing PIV..."
                    /usr/bin/ykman piv reset -f|| fail "Failed to erase PIV configuration"  # Erasing PIV configuration
                    /usr/bin/echo  -e "\PIV erased successfully!"
                fi;;
            2)
                /usr/bin/echo 
                read -s -p "Enter new PIN: " new_pin
                /usr/bin/echo 
                /usr/bin/ykman piv access change-pin -n "$new_pin" || fail "Failed to change PIN."  # Change PIN
                /usr/bin/echo  -e "\nPIN changed successfully!"
                ;;
            3) /usr/bin/echo  -e "\n\e[1;33mReturning to Interfaces\e[0m";break;;  # Return to Interfaces menu
            *) /usr/bin/echo  -e "\n\e[1;31mNot a valid number!\e[0m\n";;  # Inform about invalid input
        esac
    done
}

# Function for starting the script
function start()
{
    local choice
    while true; do
                /usr/bin/echo  -e "\n+++++++++++++++++++++++++ INTERFACES ++++++++++++++++++++++++++\n\nChoose which interface you want to setup or change config:\n\n0) FIDO\n1) PIV\n2) OpenPGP\n3) OTP\n4) Exit\n"
        read -p "Write the corresponding number here (0/1/2/3/4): " choice
        choice="${choice,,}"  # Convert to lowercase

        case $choice in
            0) fido    || start;;                                               # Call FIDO function and start again if necessary
            1) piv     || start;;                                               # Call PIV function and start again if necessary
            2) openpgp || start;;                                               # Call OpenPGP function and start again if necessary
            3) otp     || start;;                                               # Call OTP function and start again if necessary
            4) /usr/bin/echo  -e "\n\e[1;33mReturning to MENU\e[0m"; break ;;     # Return to main menu
            *) /usr/bin/echo  -e "\n\e[1;31mNot a valid number!\e[0m\n";;         # Inform about invalid input
        esac
    done
}

# Function for OpenPGP interface
function openpgp()
{
    local choice
    while true; do
        /usr/bin/echo  -e "\n+++++++++++++++++++++++++++ OPENPGP +++++++++++++++++++++++++++\n\nChoose which action you want to perform:\n\n0) Complete SetUp\n1) Erase interface\n2) Options\n3) Return to Interfaces\n"

        read -p "Write the corresponding number here (0/1/2/3): " choice
        choice="${choice,,}"  # Convert to lowercase

        case $choice in
            0)
                /usr/bin/echo  -e "\nWelcome, if it is the first SetUp remember that df PIN is 123456, df ADMIN PIN is 12345678\n"
                read -s -p "Enter new PIN: " new_pin
                /usr/bin/echo 
                /usr/bin/ykman openpgp access change-pin -n "$new_pin" || fail "Failed to change PIN."  # Change PIN
                /usr/bin/echo  -e "\nPIN changed successfully!"
                /usr/bin/echo 
                read -s -p "Enter new ADMIN PIN (must be in range 8-127): " new_pin
                /usr/bin/echo 
                /usr/bin/ykman openpgp access change-reset-code -n "$new_pin" || fail "Failed to change ADMIN PIN."  # Change Admin PIN
                /usr/bin/echo  -e "\nADMIN PIN changed successfully!"
                /usr/bin/echo 
                read -p "Would you like to set a Reset PIN (Admin PIN needed)? (Y/n): " choice
                choice="${choice,,}"  # Convert to lowercase
                if [ "$choice" != "n" ]; then
                    /usr/bin/echo 
                    read -s -p "Enter new Reset PIN (must be in range 8-127): " new_pin
                    /usr/bin/ykman openpgp access change-reset-code -r "$new_pin" || fail "Failed to set Reset PIN"  # Set Reset PIN
                    /usr/bin/echo  -e "\nReset PIN set successfully!"
                fi;;
            1)
                /usr/bin/echo 
                read -p "Are you sure to erase current OpenPGP configuration? (Y/n): " choice
                choice="${choice,,}"  # Convert to lowercase
                if [ "$choice" != "n" ]; then
                    /usr/bin/echo  -e "\nErasing OpenPGP..."
                    /usr/bin/ykman openpgp reset || fail "Failed to erase OpenPGP configuration"  # Reset OpenPGP
                    /usr/bin/echo  -e "\nOpenPGP erased successfully!"
                fi;;
            2)
                local choice
                while true; do
                    /usr/bin/echo  -e "\n\nChoose option:\n\n0) Change PIN\n1) Set the number of retry attempts for the every PIN (not every YK allows it)\n2) Set the Signature PIN policy (not every YK allows it)\n3) Return to OpenPGP Interface\n"

                    read -p "Write the corresponding number here (0/1/2/3): " choice
                    choice="${choice,,}"  # Convert to lowercase

                    case $choice in
                        0)
                            /usr/bin/echo  -e "\nRemember that default PIN is 123456\n"
                            read -s -p "Enter new PIN: " new_pin
                            /usr/bin/echo 
                            /usr/bin//usr/bin/ykman openpgp access change-pin -n "$new_pin" || fail "Failed to change PIN."  # Change PIN
                            /usr/bin/echo  -e "\nPIN changed successfully!"
                            /usr/bin/echo ;;
                        1)
                            /usr/bin/echo 
                            read -s -p "Enter PIN retry attemps: " n1
                            /usr/bin/echo 
                            read -s -p "Enter Admin PIN retry attemps: " n2
                            /usr/bin/echo 
                            read -s -p "Enter Reset Code retry attemps: " n3
                            /usr/bin/echo 
                            /usr/bin//usr/bin/ykman openpgp access set-retries "$n1" "$n2" "$n3" || fail "Unable to set PINs retries"  # Setting PINs attemps
                            /usr/bin/echo  -e "\nConfiguration set successfully!";;
                        2)
                            /usr/bin/echo 
                            read -s -p "Choose Once (o) or Always (a) for your signature policy! (o/A): " choice
                            choice="${choice,,}"  # Convert to lowercase
                            if [ "$choice" != "o" ]; then
                                /usr/bin/ykman openpgp access set-signature-policy always || fail "Failed to set signature policy"  # Set signature policy to always
                            else
                                /usr/bin/ykman openpgp access set-signature-policy once || fail "Failed to set signature policy"  # Set signature policy to once
                            fi
                            /usr/bin/echo  -e "\nConfiguration set successfully!";;
                        3) /usr/bin/echo  -e "\n\e[1;33mReturning to OpenPGP\e[0m";break;;  # Exit to OpenPGP menu
                        *) /usr/bin/echo  -e "\n\e[1;31mNot a valid number!\e[0m\n";; # Inform about invalid input
                    esac
                done
                ;;
            3) /usr/bin/echo  -e "\n\e[1;33mReturning to Interfaces\e[0m";break;;  # Return to Interfaces menu
            *) /usr/bin/echo  -e "\n\e[1;31mNot a valid number!\e[0m\n";;  # Inform about invalid input
        esac
    done
}

# Function for OTP interface
function otp()
{
    # Placeholder for OTP interface implementation
    /usr/bin/echo  -e "\nOTP interface not implemented yet"
    start
}

# Main script starts here

# Call the start function to begin the script
start

./YK_Menu.sh  # Start the YK_Menu script
