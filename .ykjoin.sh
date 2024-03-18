

# Function to restart SSH Agent and add YubiKey interface
function ykjoin() {
    PKCS11PATH=$(find /usr/lib -name 'opensc-pkcs11.so' | head -n 1)
    echo -e '\nRestarting SSH Agent\n'
    pkill ssh-agent
    eval $(ssh-agent)
    echo
    ssh-add -s $PKCS11PATH
    echo -e '\nThis is your identity:\n'
    ssh-add -l
}
