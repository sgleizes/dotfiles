#!/bin/bash
# This script is meant to be run periodically by a systemd timer.
# See /etc/systemd/system/cifs-automount-guard.service and /etc/systemd/system/cifs-automount-guard.timer

set -e

MINT_THINKPAD=mint-thinkpad.local
SAMBA_PORT=445 # Samba port

# Usage: automount_guard host port units...
function automount_guard {
  local host="$1"
  local port="$2"
  local units=("${@:3}")

  if timeout 1 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
    echo ":: mint-thinkpad available, starting automounts..."

    for unit in "${units[@]}"; do
      systemctl start "$unit.automount"
    done
  else
    echo ":: mint-thinkpad not available, stopping automounts..."

    for unit in "${units[@]}"; do
      systemctl stop "$unit.automount"
    done
  fi
}

automount_guard "$MINT_THINKPAD" "$SAMBA_PORT" mnt-smb-HOMEWORLD mnt-smb-RIFTER
