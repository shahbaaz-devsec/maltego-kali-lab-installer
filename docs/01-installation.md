# Installation Guide

This guide explains how to install Maltego CE on Kali Linux using the automated installer.

---

## One-Line Installation

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/shahbaaz-devsec/maltego-kali-lab-installer/main/scripts/maltego_kali_lab_installer.sh)
````

---

## What the Installer Does

The installer automatically:

* Checks if Maltego is already installed
* Installs Maltego from Kali repositories
* Installs Java 21 if missing
* Sets Java 21 as the default Java runtime
* Applies Maltego Java compatibility fixes
* Creates a structured workspace
* Starts Maltego automatically

---

## Workspace Location

The installer creates the workspace here:

```text
~/footprinting-lab-testfire/maltego
```

Inside it:

```text
graphs/
exports/
maltego-launch.log
```

---

## Manual Installation

Clone the repository:

```bash
git clone https://github.com/shahbaaz-devsec/maltego-kali-lab-installer.git
cd maltego-kali-lab-installer
```

Make the installer executable:

```bash
chmod +x scripts/maltego_kali_lab_installer.sh
```

Run the installer:

```bash
./scripts/maltego_kali_lab_installer.sh
```

---

## Expected Result

Maltego should launch automatically and show the activation screen.

---

## Requirements

* Kali Linux
* Internet connection
* Sudo privileges
* GUI desktop environment

---

## Notes

Maltego may take 10–30 seconds to launch on first run.

If the activation screen appears, continue inside the Maltego GUI.
