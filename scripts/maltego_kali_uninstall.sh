#!/usr/bin/env bash
set -Eeuo pipefail

PURGE_USER_DATA="${PURGE_USER_DATA:-1}"

log()  { printf '\033[1;34m[*]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[+]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m[X]\033[0m %s\n' "$*" >&2; }

if [[ "${EUID}" -eq 0 ]]; then
    fail "Run this script as a normal user, not root."
    exit 1
fi

sudo -v

kill_maltego_processes() {
    log "Stopping Maltego processes safely"

    pkill -f "/usr/share/maltego/bin/maltego" 2>/dev/null || true
    pkill -f "java.*maltego" 2>/dev/null || true

    sleep 2

    pkill -9 -f "/usr/share/maltego/bin/maltego" 2>/dev/null || true
    pkill -9 -f "java.*maltego" 2>/dev/null || true

    ok "Maltego processes stopped"
}

remove_maltego_package() {
    log "Purging Maltego package"

    if dpkg-query -W -f='${Status}' maltego 2>/dev/null | grep -q "install ok installed"; then
        sudo apt purge -y maltego
        ok "Maltego package purged"
    elif dpkg -l 2>/dev/null | grep -qi '^..[[:space:]]*maltego[[:space:]]'; then
        sudo apt purge -y maltego
        ok "Maltego package purged"
    else
        warn "Maltego package is not installed"
    fi
}

remove_leftover_binary() {
    log "Removing leftover Maltego binaries"

    sudo rm -f /usr/bin/maltego
    sudo rm -f /usr/local/bin/maltego

    hash -r 2>/dev/null || true

    ok "Leftover binaries removed"
}

remove_user_data() {
    if [[ "${PURGE_USER_DATA}" == "1" ]]; then
        log "Removing Maltego user data"

        rm -rf "$HOME/.maltego"
        rm -rf "$HOME/.config/maltego"
        rm -rf "$HOME/.cache/maltego"
        rm -rf "$HOME/.local/share/maltego"

        ok "User data removed"
    else
        warn "Skipping user data removal"
    fi
}

cleanup_system() {
    log "Removing unused dependencies"

    sudo apt autoremove -y
    sudo apt clean

    ok "System cleanup complete"
}

verify_uninstall() {
    log "Verifying Maltego removal"

    local failed=0

    if command -v maltego >/dev/null 2>&1; then
        warn "Maltego binary still found at: $(command -v maltego)"
        failed=1
    else
        ok "maltego not found"
    fi

    if dpkg-query -W -f='${Status}' maltego 2>/dev/null | grep -q "install ok installed"; then
        warn "Maltego package still installed"
        dpkg -l | grep -i maltego || true
        failed=1
    else
        ok "maltego package not installed"
    fi

    if ls -ld "$HOME/.maltego" "$HOME/.config/maltego" "$HOME/.cache/maltego" "$HOME/.local/share/maltego" >/dev/null 2>&1; then
        warn "Some Maltego user files still exist"
        ls -ld "$HOME/.maltego" "$HOME/.config/maltego" "$HOME/.cache/maltego" "$HOME/.local/share/maltego" 2>/dev/null || true
        failed=1
    else
        ok "maltego user files removed"
    fi

    if [[ "$failed" -eq 0 ]]; then
        ok "Maltego fully uninstalled"
    else
        warn "Uninstall completed, but some leftovers may remain"
    fi
}

main() {
    echo "=============================================="
    echo "  Maltego Kali Full Uninstaller"
    echo "=============================================="
    echo

    kill_maltego_processes
    remove_maltego_package
    remove_leftover_binary
    remove_user_data
    cleanup_system
    verify_uninstall

    echo
    ok "Uninstallation complete"
}

main "$@"
