#!/bin/bash
echo "Cleaning up the package files"
if [ -d /var/lib/analytic-app ]; then
    rm -rf /var/lib/analytic-app
fi
echo "Cleaning up the init file"
if [ -f /etc/init.d/analytic-app ]; then
    rm -f /etc/init.d/analytic-app
fi
