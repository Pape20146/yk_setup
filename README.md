# YubiKey SetUp in Bash (for Ubuntu)

## Idea and Objective

My idea for this project was to enable future hypothetical users to achieve in a few minutes what took me three weeks of studying various YubiKey configurations. By condensing the not so easy process of configuring YubiKey settings with a user-friendly and efficient script, users can swiftly explore and implement different configurations without the extensive time investment typically required. The objective is to empower users to quickly grasp and utilize the full potential of YubiKey devices, leveraging automation to streamline the process and enhance overall efficiency.
<br>

## Overview  :writing_hand:

The YubiKey SetUp Project consists of several shell scripts that automate various tasks related to YubiKey devices. These scripts are designed to streamline the process of setting up and configuring YubiKeys on Ubuntu systems, enhancing security and ease of use for users. The scripts are:

- **YK_Menu.sh**: The YK_Menu.sh script serves as the central menu interface for users to navigate through various YubiKey management tasks.
  
- **YK_Config.sh**: This script provides an interactive menu interface for configuring different aspects of YubiKey devices, such as FIDO, PIV, and OpenPGP (OTP not set yet). Users can easily change PINs, erase configurations, and set various options based on their requirements.
  
- **YK_Download.sh**: This script automates the download and installation of essential packages required for YubiKey functionality setup. It checks for the presence of necessary packages like OpenSC, YubiKey Manager, and libpam-u2f. If these packages are not found, it adds the Yubico repository, updates the package list, and installs the required packages.
  
- **YK_Sudo.sh**: The YK_Sudo.sh script automates various tasks like the installation of necessary packages, erases FIDO configurations, changes PINs, moves keys to specific directories, modifies PAM configurations, and performs other setup tasks required for YubiKey integration with sudo access. :warning:NOT WORKING:warning:
  
- **YK_SSH_PIV.sh**: This script automates the setup of YubiKey for SSH PIV authentication. It installs required packages, detects YubiKey devices, erases PIV configurations, changes PINs, generates keys and certificates, and adds the private key to the SSH agent, among other tasks.
  
- **YK_SSH_FIDO.sh**: This script automates the setup of YubiKey for SSH FIDO authentication. It is useful because it lets you use elliptical keys for SSH (PIV doesn’t support it). Note that FIDO works only on Linux systems.
  
- **YK_Functions.sh**: YK_Functions.sh script provides reusable functions that can be used by other scripts in the project. It includes functions for handling failures, starting the script, listing available functions, and creating functions in the ~/.bashrc file for easier YubiKey management.
<br>

## How to Use :hammer:

To effectively use the YubiKey SetUp program, follow these steps:

:gear: First of all clone this directory on your pc.

:gear: Once the files are in place, access the directory via the terminal and grant execution permissions to all bash files using the command `sudo chmod +x YK*`. This step ensures that each file can be executed as a program.

:gear: With the execution permissions set, initiate the program by executing the command `./YK_Menu.sh` in the terminal. This action launches the main menu interface, allowing you to navigate through various configuration options and manage your YubiKey device effectively.
<br>

## SSH :closed_lock_with_key: 

It's important to highlight the capabilities and limitations of using PIV and FIDO for SSH authentication. With PIV, users can generate RSA keys of varying lengths (2048, 3072, 4096), but it does not support generating elliptic curve keys like ed25519, which requires firmware version 5.7 or later. To address this limitation, FIDO support has been implemented, focusing on elliptic curve keys.

It's crucial to note that while FIDO offers robust support thanks to PKCS#11, it's limited to Linux environments. On the other hand, PIV is compatible with a wider range of devices.

Currently, the choice between RSA and ECC (elliptic curve cryptography) keys doesn't significantly impact security, as both offer strong cryptographic properties. Therefore, users can confidently choose either option based on their specific requirements and compatibility constraints.
<br>

## Known Issues :no_entry: 

It's important to note a couple of potential issues that users might encounter.

**:x: YK_SSH**: Firstly, concerning SSH key creation, users may experience erratic behavior from the SSH agent, leading to unexpected outcomes. If any issues arise during SSH key creation or usage, it's advisable to check the SSH agent for any anomalies and restart it.

**:x: YK_Sudo**: Secondly, there might be inconsistencies with the sudo integration. While the script attempts to automate sudo configuration, it may not always work as expected. In some cases, sudo functionality may be disrupted, effectively blocking its usage. If sudo commands fail to execute properly, users should troubleshoot the sudo configuration to ensure proper functionality. If you want to do it manually follow this step-by-step tutorial (it has always worked for me).

**:x: YK_Config**: Additionally, it's crucial to highlight that not all YubiKey models support all configuration options. Certain settings may not be available or might behave differently depending on the YubiKey version. Users are advised to consult the official Yubico website for specific details regarding their YubiKey model to ensure compatibility and functionality with the script's configuration options.
<br>

## Notes :ledger:

:pencil2: Users have the flexibility to extend the functionality of the script by adding additional code to accommodate other YubiKey actions or configurations. This can be achieved by incorporating new options within the case statement in the YK_Menu file to provide access to these additional features.

:pencil2: If there's a need to expand the configuration capabilities beyond FIDO and PIV to include options for OpenPGP and OTP, these can be seamlessly integrated into the YK_Config file alongside existing functionalities. This ensures that users can easily manage various aspects of their YubiKey configurations within a unified framework.

:pencil2: Users can enhance the functionality of their ~/.bashrc file by incorporating new functions using the YK_Functions file. This provides a convenient way to extend the script's capabilities and tailor it to specific use cases or preferences, offering greater versatility and customization options for YubiKey management.
