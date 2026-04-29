#!/usr/bin/env bash

set -euo pipefail

TARGET="${TARGET:-example.com}"
LAB_ROOT="${LAB_ROOT:-$HOME/maltego-lab}"
MALTEGO_DIR="${LAB_ROOT}/maltego"

JAVA21_PATH="/usr/lib/jvm/java-21-openjdk-amd64"
MALTEGO_VERSION_DIR="$HOME/.maltego/v4.11.2"
MALTEGO_USER_CONF="${MALTEGO_VERSION_DIR}/etc/maltego.conf"

MALTEGO_PROCESS_PATTERN="/usr/share/maltego/bin/maltego"

log()  { printf '\033[1;34m[*]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[+]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m[X]\033[0m %s\n' "$*" >&2; }

ensure_maltego_installed() {
    log "Checking Maltego installation..."
    if command -v maltego >/dev/null 2>&1; then
        ok "Maltego is installed"
        return 0
    fi
    warn "Installing Maltego..."
    sudo apt update
    sudo apt install -y maltego
    ok "Maltego installed"
}

ensure_java21_installed() {
    log "Checking Java 21..."
    if [[ -x "${JAVA21_PATH}/bin/java" ]]; then
        ok "Java 21 found"
        return 0
    fi
    warn "Installing Java 21..."
    sudo apt update
    sudo apt install -y openjdk-21-jdk
    ok "Java 21 installed"
}

ensure_default_java_21() {
    log "Setting Java 21 as default..."
    sudo update-alternatives --set java "${JAVA21_PATH}/bin/java" || true
    ok "Java configured"
}

configure_maltego_for_java21() {
    log "Configuring Maltego..."

    mkdir -p "${MALTEGO_VERSION_DIR}/etc"

    cat > "${MALTEGO_USER_CONF}" <<EOF
default_options="--branding maltego -J-Xmx2048m -J-XX:+UseG1GC -J-XX:+IgnoreUnrecognizedVMOptions"
jdkhome="${JAVA21_PATH}"
EOF

    ok "Configuration applied"
}

build_lab_folders() {
    log "Creating workspace..."

    mkdir -p "${MALTEGO_DIR}/graphs"
    mkdir -p "${MALTEGO_DIR}/exports"
    mkdir -p "${LAB_ROOT}/screenshots"

    ok "Workspace ready"
}

kill_stale_maltego() {
    if pgrep -f "${MALTEGO_PROCESS_PATTERN}" >/dev/null 2>&1; then
        warn "Stopping existing Maltego..."
        pkill -f "${MALTEGO_PROCESS_PATTERN}" || true
        sleep 2
        pkill -9 -f "${MALTEGO_PROCESS_PATTERN}" 2>/dev/null || true
    fi
}

launch_maltego() {
    log "Launching Maltego..."

    nohup maltego > "${MALTEGO_DIR}/maltego.log" 2>&1 &
    disown

    ok "Maltego started"
}

print_next_steps() {
    cat <<EOF

==============================================
 Maltego Setup Complete
==============================================

Target example: ${TARGET}
Workspace: ${MALTEGO_DIR}

==============================================

EOF
}

main() {
    echo "=============================================="
    echo "  Maltego Kali Installer"
    echo "=============================================="

    ensure_maltego_installed
    ensure_java21_installed
    ensure_default_java_21
    configure_maltego_for_java21
    build_lab_folders
    kill_stale_maltego
    launch_maltego
    print_next_steps
}

main "$@"
