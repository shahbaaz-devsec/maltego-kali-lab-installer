# Usage Guide

This guide explains how to use Maltego after installation.

---

## Launching Maltego

The installer launches Maltego automatically.

To launch it later manually:

```bash
maltego
````

---

## First Run

When Maltego opens:

1. Select **Maltego ID**
2. Log in or create an account
3. Complete the activation wizard
4. Allow Maltego to install standard transforms

---

## Create a New Graph

Inside Maltego:

1. Click **File**
2. Click **New**
3. A blank graph workspace will open

---

## Add a Domain Entity

1. Search for **Domain** in the entity palette
2. Drag **Domain** onto the canvas
3. Change the domain value to your target

Example:

```text
example.com
```

---

## Run Transforms

Right-click the domain entity and choose:

```text
Run Transform → All Transforms
```

Or use a machine:

```text
Machines → Run Machine → Footprint L2
```

---

## Save Results

Recommended output locations:

```text
~/footprinting-lab-testfire/maltego/graphs/
~/footprinting-lab-testfire/maltego/exports/
```

Save graph:

```text
graph.mtgx
```

Export results:

```text
entities.csv
graph.png
```

---

## Logs

Installer launch log:

```text
~/footprinting-lab-testfire/maltego/maltego-launch.log
```

---

## Important Notes

* Maltego requires login/activation
* First launch may take 10–30 seconds
* Some transforms may require API keys
* Use only for authorized OSINT and investigations

Tell me when done.
