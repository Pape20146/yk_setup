

# Function to run YubiKey configuration menu directly
function ykmenu() {
    YKMenuPath=$(sudo find / -name 'YK_Menu.sh' 2>/dev/null | head -n 1)
    if [ -n "$YKMenuPath" ]; then
        cd $(dirname $YKMenuPath)
        ./YK_Menu.sh
    else
        echo 'YubiKey menu script not found.'
    fi
}
