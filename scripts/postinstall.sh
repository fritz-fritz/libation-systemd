#!/bin/sh
# determine real user (if apt was run under sudo)
USER="${SUDO_USER:-$(logname 2>/dev/null || echo root)}"
if [ "$USER" != "root" ] && command -v runuser >/dev/null 2>&1; then
    echo "Running interactive setup for $USER…"
    runuser -l "$USER" -c "/usr/bin/setup-libation-systemd" || true
else
    echo ""
    echo "To finish setup, please run as your user:"
    echo "  setup-libation-systemd"
    echo ""
fi