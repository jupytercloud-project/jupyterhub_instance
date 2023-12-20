
#!/usr/bin/env bash

# DEACTIVATED
# DEACTIVATED
# DEACTIVATED
# DEACTIVATED
exit 0

set -x

#
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=864681#17
#
# Since 1.9.11, apt(8) now waits for dpkg locks by default,
# apt-get(8) needs to be passed -o dpkg::lock::timeout=$seconds,
# where $seconds is either the seconds to wait or -1 to wait indefinitely.
#
# https://askubuntu.com/questions/132059/how-to-make-a-package-manager-wait-if-another-instance-of-apt-is-running
# https://askubuntu.com/questions/1077215/how-does-apt-get-use-var-cache-apt-archives-lock
# https://saveriomiroddi.github.io/Handling-the-apt-lock-on-ubuntu-server-installations/
#
# THIS IS NEEDED FOR UBUNTU < 20.04
#
export DEBIAN_FRONTEND=noninteractive

function apt_wait_for_lock {
    local state_dir_path="$(
        apt-config shell StateDir Dir::State/d \
      | sed --regexp-extended 's/(.+)='\''([^'\'']+)'\''/\2/'
    )"
    sudo -E /usr/bin/flock \
             --wait 900 \
             --no-fork \
             --verbose \
             "${state_dir_path}/daily_lock" \
             /usr/bin/apt $@

}

function main {
    apt_wait_for_lock update
    apt_wait_for_lock -y upgrade
    apt_wait_for_lock -y \
        install \
            jq rsync vim \
            qemu-guest-agent
}

main $@