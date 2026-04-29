# Troubleshooting Guide

This guide covers common Maltego installation and launch issues on Kali Linux.

---

## Maltego does not launch

Stop existing Maltego processes:

```bash
pkill -f "/usr/share/maltego/bin/maltego" || true
pkill -f "java.*maltego" || true
````

Launch manually:

```bash
maltego
```

---

## Java compatibility errors

Common symptoms:

```text
IllegalAccessError
InaccessibleObjectException
NullPointerException
sun.security.ssl
sun.awt
```

Cause:

Modern Java blocks access to internal modules required by Maltego.

Fix:

The installer writes a custom Maltego config file:

```text
~/.maltego/v4.11.2/etc/maltego.conf
```

This config forces Maltego to use Java 21 with required compatibility flags.

---

## Maltego package installed but command not found

Check package:

```bash
dpkg-query -W -f='${Status}\n' maltego
```

Check binary:

```bash
command -v maltego
```

If broken, reinstall:

```bash
sudo apt purge -y maltego
sudo apt install -y maltego
```

---

## Activation wizard does not appear

Wait 10–30 seconds.

Check launch log:

```bash
cat ~/footprinting-lab-testfire/maltego/maltego-launch.log
```

---

## Reset Maltego environment

Run the one-line uninstaller:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/shahbaaz-devsec/maltego-kali-lab-installer/main/scripts/maltego_kali_uninstall.sh)
```

Then reinstall:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/shahbaaz-devsec/maltego-kali-lab-installer/main/scripts/maltego_kali_lab_installer.sh)
```

---

## Verify clean uninstall

```bash
command -v maltego || echo "maltego not found"
dpkg-query -W -f='${Status}\n' maltego 2>/dev/null || echo "maltego package not installed"
```

Expected:

```text
maltego not found
maltego package not installed
```

---

## APT issues

If Kali package lists are broken:

```bash
sudo apt clean
sudo apt update
```

Then retry installation.

---

## Important Notes

* Do not run the installer as root
* Run as normal Kali user with sudo privileges
* Maltego requires GUI access
* Some transforms require additional API keys

Tell me when done.
