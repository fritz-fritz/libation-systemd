# libation-systemd

[![Release](https://img.shields.io/github/v/release/fritz-fritz/libation-systemd)](https://github.com/fritz-fritz/libation-systemd/releases) [![Github All Releases](https://img.shields.io/github/downloads/fritz-fritz/libation-systemd/total.svg)](https://github.com/fritz-fritz/libation-systemd/releases/)  
[![License](https://img.shields.io/badge/license-GPL%20v3-blue?logo=GPLv3&logoSize=auto)](COPYING) [Platform](https://img.shields.io/badge/platform-Linux-lightgrey?logo=linux)

> User systemd units and helpers to mount S3 storage via rclone and launch Libation with warm caches and clean teardown.

---

This project is for use with the wonderful application [Libation](https://github.com/rmcrackan/Libation).

## ✨ Features

- Automated migration of existing files to S3
- Seamless [rclone](https://rclone.org/) S3/B2 mount in a dedicated systemd `app-libation.slice`
- Automated VFS cache warm-up via `libation-s3-warmup.service` to improve application launch times
- One-shot setup helper: [setup-libation-systemd](scripts/setup-libation-systemd)
- Packaged with nfpm: [packaging/nfpm.yaml](packaging/nfpm.yaml)
- Minimal dependencies: `rclone`, `fuse3`, `libation`, `libnotify`

---

## 🚀 Quickstart

### 1. Install Package

```bash
# Debian/Ubuntu
$ sudo apt install ./libation-systemd_*.deb

# Fedora/RHEL
$ sudo rpm -Uvh libation-systemd-*.rpm

# Or unpack tarball
$ sudo tar -xzf libation-systemd-*.tar.gz -C /usr/share/
```

### 2. Run Setup Helper (if needed)

```bash
setup-libation-systemd
```

The setup helper should run automatically on install if using a release package but can be run manually.

This will:

- Copy systemd units from /usr/share/libation-systemd/systemd/user
- Initialize your env file from config/env.example
- Prompt for S3 credentials, bucket & mountpoint
- Reload user units with systemctl --user daemon-reload

The helper can also be run for each user that needs to be setup if executed as that user.

### 3. Start Libation stack

```bash
systemctl --user start libation.service
```

### 4. Tail logs to verify health

```bash
journalctl --user -f \
  -u libation.service \
  -u libation-s3.service \
  -u libation-s3-warmup.service
```

#### Or tail the slice

```bash
journalctl --user -xefu libation.slice
```

#### Check the control group tree

```bash
systemd-cgls
```

### 5. Enable launch on login (Optional)

```bash
systemctl --user enable libation.service
```
