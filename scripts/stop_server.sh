#!/bin/bash
echo "Stopping the server"
if [ -f /etc/init.d/analytic-app-setup ]; then
    echo "analytic-app-setup file present"
    /etc/init.d/analytic-app-setup stop
    echo "server stopped"
fi
