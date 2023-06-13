#!/bin/bash
echo "Cleaning up the package files"
if [ -d /var/lib/analytic-app-setup ]; then
    rm -rf /var/lib/analytic-app-setup
fi
echo "Cleaning up the init file"
if [ -f /etc/init.d/analytic-app-setup ]; then
    rm -f /etc/init.d/analytic-app-setup
fi
