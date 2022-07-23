#!/bin/bash --login
# The --login ensures the bash configuration is loaded,
# enabling Conda.
installed_file="/usr/share/.hummingbot_installed"

if [ ! -f "$installed_file" ]; 
then
    echo "Doing one-time installation of dependencies"
    install_hummingbot
    install_custom_deps
    touch "$installed_file"
fi
exec $@