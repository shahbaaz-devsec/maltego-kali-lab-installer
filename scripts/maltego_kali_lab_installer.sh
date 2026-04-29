#!/usr/bin/env bash

set -euo pipefail

readonly TARGET_A="test"
readonly TARGET_B="fire"
readonly TARGET_C="net"
readonly TARGET="${TARGET_A}${TARGET_B}.${TARGET_C}"

readonly LAB_ROOT="${HOME}/footprinting-lab-testfire"
readonly MALTEGO_DIR="${LAB_ROOT}/maltego"

readonly JAVA21_PATH="/usr/lib/jvm/java-21-openjdk-amd64"
readonly MALTEGO_VERSION_DIR="${HOME}/.maltego/v4.11.2"
readonly MALTEGO_USER_CONF="${MALTEGO_VERSION_DIR}/etc/maltego.conf"

readonly MALTEGO_PROCESS_PATTERN="/usr/share/maltego/bin/maltego"

log()  { printf '\033[1;34m[*]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[+]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m[X]\033[0m %s\n' "$*" >&2; }

ensure_maltego_installed() {
    log "Checking Maltego installation..."
    if command -v maltego >/dev/null 2>&1; then
        ok "Maltego is installed at $(which maltego)"
        return 0
    fi
    warn "Maltego not found. Installing via apt..."
    sudo apt update
    sudo apt install -y maltego
    ok "Maltego installed"
}

ensure_java21_installed() {
    log "Checking Java 21 availability..."
    if [[ -d "${JAVA21_PATH}" ]] && [[ -x "${JAVA21_PATH}/bin/java" ]]; then
        ok "Java 21 is installed at ${JAVA21_PATH}"
        return 0
    fi
    warn "Java 21 not found. Installing openjdk-21-jdk..."
    sudo apt update
    sudo apt install -y openjdk-21-jdk
    if [[ ! -d "${JAVA21_PATH}" ]]; then
        fail "Java 21 install completed but ${JAVA21_PATH} not present"
        return 1
    fi
    ok "Java 21 installed"
}

ensure_default_java_21() {
    log "Setting system default Java to 21..."
    if ! sudo update-alternatives --list java 2>/dev/null | grep -q "java-21-openjdk-amd64"; then
        warn "Java 21 not registered with update-alternatives; registering..."
        sudo update-alternatives --install /usr/bin/java java "${JAVA21_PATH}/bin/java" 2111
    fi
    sudo update-alternatives --set java "${JAVA21_PATH}/bin/java"
    local current_java
    current_java=$(java -version 2>&1 | head -1)
    if [[ "${current_java}" == *'"21'* ]]; then
        ok "System Java is now: ${current_java}"
    else
        warn "System Java reports: ${current_java}"
        warn "Maltego may still work via the user config; continuing anyway"
    fi
}

configure_maltego_for_java21() {
    log "Configuring Maltego to use Java 21..."
    mkdir -p "${MALTEGO_VERSION_DIR}/etc"
    if [[ -f "${MALTEGO_USER_CONF}" ]] && [[ ! -f "${MALTEGO_USER_CONF}.original" ]]; then
        cp "${MALTEGO_USER_CONF}" "${MALTEGO_USER_CONF}.original"
        log "Backed up original config to ${MALTEGO_USER_CONF}.original"
    fi
    cat > "${MALTEGO_USER_CONF}" <<EOF
default_options="--branding maltego -J-Xmx2560m -J-XX:+UseG1GC -J-Dsun.java2d.xrender=false -J-Dsun.java2d.opengl=false -J-Dsun.java2d.d3d=false --locale en:US -J--add-opens=java.base/java.net=ALL-UNNAMED -J--add-opens=java.base/java.lang.ref=ALL-UNNAMED -J--add-opens=java.base/java.lang=ALL-UNNAMED -J--add-opens=java.base/java.security=ALL-UNNAMED -J--add-opens=java.base/java.util=ALL-UNNAMED -J--add-opens=java.desktop/javax.swing.plaf.basic=ALL-UNNAMED -J--add-opens=java.desktop/javax.swing.text=ALL-UNNAMED -J--add-opens=java.desktop/javax.swing=ALL-UNNAMED -J--add-opens=java.desktop/java.awt=ALL-UNNAMED -J--add-opens=java.desktop/java.awt.event=ALL-UNNAMED -J--add-opens=java.prefs/java.util.prefs=ALL-UNNAMED -J--add-exports=java.desktop/sun.awt=ALL-UNNAMED -J--add-exports=java.desktop/java.awt.peer=ALL-UNNAMED -J--add-exports=java.desktop/com.sun.beans.editors=ALL-UNNAMED -J--add-exports=java.desktop/sun.swing=ALL-UNNAMED -J--add-exports=java.desktop/sun.awt.im=ALL-UNNAMED -J--add-exports=java.base/java.nio=ALL-UNNAMED -J--add-exports=jdk.internal.jvmstat/sun.jvmstat.monitor=ALL-UNNAMED -J--add-exports=java.management/sun.management=ALL-UNNAMED -J--add-exports=java.base/sun.reflect.annotation=ALL-UNNAMED -J--add-opens=java.desktop/sun.awt.X11=ALL-UNNAMED -J--add-opens=java.desktop/javax.swing.plaf.synth=ALL-UNNAMED -J--add-opens=java.desktop/com.sun.java.swing.plaf.gtk=ALL-UNNAMED -J--add-opens=java.desktop/sun.awt.shell=ALL-UNNAMED -J--add-opens=java.desktop/sun.awt.im=ALL-UNNAMED -J--add-opens=java.base/java.nio=ALL-UNNAMED -J-XX:+IgnoreUnrecognizedVMOptions -J--add-opens=java.desktop/javax.swing.text.html=ALL-UNNAMED -J--add-exports=java.base/sun.security.ssl=ALL-UNNAMED -J--add-exports=java.desktop/sun.awt.image=ALL-UNNAMED"
jdkhome="${JAVA21_PATH}"
EOF
    if ! grep -q "^jdkhome=\"${JAVA21_PATH}\"$" "${MALTEGO_USER_CONF}"; then
        fail "jdkhome not set correctly in ${MALTEGO_USER_CONF}"
        return 1
    fi
    if ! grep -q 'sun.security.ssl=ALL-UNNAMED' "${MALTEGO_USER_CONF}"; then
        fail "sun.security.ssl flag missing from ${MALTEGO_USER_CONF}"
        return 1
    fi
    ok "Maltego configured to use Java 21"
}

build_lab_folders() {
    log "Building Maltego lab folder structure under ${MALTEGO_DIR}"
    mkdir -p "${MALTEGO_DIR}/graphs" "${MALTEGO_DIR}/exports" "${LAB_ROOT}/screenshots/phase3-maltego"
    ok "Folder structure ready"
}

kill_stale_maltego() {
    if pgrep -f "${MALTEGO_PROCESS_PATTERN}" >/dev/null 2>&1; then
        warn "Existing Maltego process detected; killing..."
        pkill -f "${MALTEGO_PROCESS_PATTERN}" || true
        sleep 2
        pkill -9 -f "${MALTEGO_PROCESS_PATTERN}" 2>/dev/null || true
        ok "Stale Maltego processes cleared"
    else
        ok "No stale Maltego processes running"
    fi
}

launch_maltego() {
    log "Launching Maltego..."
    log "First-run will be slow (Java warm-up takes 10-30 seconds)"
    local maltego_log="${MALTEGO_DIR}/maltego-launch.log"
    nohup maltego > "${maltego_log}" 2>&1 &
    disown
    local maltego_pid=$!
    log "Maltego started with PID ${maltego_pid}"
    log "Launch log: ${maltego_log}"
    sleep 5
    if ! kill -0 "${maltego_pid}" 2>/dev/null; then
        if pgrep -f "${MALTEGO_PROCESS_PATTERN}" >/dev/null 2>&1; then
            ok "Maltego launcher exited but Maltego JVM is running. Splash should appear."
            return 0
        fi
        fail "Maltego died within 5 seconds of launch"
        fail "Check the launch log:"
        echo
        tail -30 "${maltego_log}"
        return 1
    fi
    ok "Maltego is running. Splash screen should appear shortly."
}

print_next_steps() {
    cat <<EOF

==============================================================================
  Maltego is launching. Continue in the Maltego GUI:
==============================================================================

  1. If activation wizard appears:
       - Pick "Maltego ID" (default)
       - Click Next, register / log in, click through the rest of the wizard
       - The wizard will install ~186 Standard Transforms automatically

  2. Once on the graph workspace:
       File -> New (Ctrl+T) to open a fresh graph

  3. Drag a Domain entity from the left palette to the canvas.

  4. Click the entity. In the Property View (bottom-right), change
     "Domain Name" from "maltego.com" to:
            ${TARGET}

  5. Save the graph as:
            ${MALTEGO_DIR}/graphs/testfire-footprint.mtgx

  6. Right-click the entity -> Run Transform -> "All Transforms"
     OR
     Use Machines -> Run Machine -> Footprint L2 with target ${TARGET}

  7. Once the graph stabilises:
       - Top toolbar -> Organic Layout (detangles nodes)
       - File -> Export -> Export Graph to Table (CSV)
            -> ${MALTEGO_DIR}/exports/maltego-entities.csv
       - File -> Export -> Export Graph as Image (PNG)
            -> ${MALTEGO_DIR}/exports/maltego-graph.png

==============================================================================
EOF
}

main() {
    echo "=============================================="
    echo "  Maltego CE Setup for Kali Linux"
    echo "  Target: ${TARGET}"
    echo "=============================================="
    echo
    if ! command -v apt >/dev/null 2>&1; then
        fail "This script requires apt (Debian/Kali). Detected non-apt system."
        exit 1
    fi
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
