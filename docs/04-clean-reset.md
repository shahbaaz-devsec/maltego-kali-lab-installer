# Clean Reset Guide

This guide explains how to completely remove Maltego and reset the environment.

---

## One-Line Clean Reset

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/shahbaaz-devsec/maltego-kali-lab-installer/main/scripts/maltego_kali_uninstall.sh)
````

---

## What the Reset Removes

The uninstall script removes:

* Maltego package
* Leftover Maltego binaries
* Maltego user configuration
* Maltego cache files
* Maltego local data
* Unused dependencies

---

## Manual Reset Commands

```bash
sudo apt purge -y maltego
sudo apt autoremove -y
sudo rm -f /usr/bin/maltego /usr/local/bin/maltego
rm -rf ~/.maltego ~/.config/maltego ~/.cache/maltego ~/.local/share/maltego
hash -r
```

---

## Verify Removal

```bash
command -v maltego || echo "maltego not found"
dpkg-query -W -f='${Status}\n' maltego 2>/dev/null || echo "maltego package not installed"
```

Expected output:

```text
maltego not found
maltego package not installed
```

---

## Reinstall After Reset

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/shahbaaz-devsec/maltego-kali-lab-installer/main/scripts/maltego_kali_lab_installer.sh)
```

---

## Notes

Use clean reset when:

* Maltego fails to launch
* Java configuration becomes corrupted
* You want a fresh install
* You are testing the installer again
