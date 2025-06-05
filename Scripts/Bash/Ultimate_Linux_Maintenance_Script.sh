#!/bin/bash
##############################################################################
# Ultimate Linux Maintenance Script – Final Pass (All Optional = ON)
# Maintainer: (Your Name)
# Version: 1.0-final
# Purpose: Safe, idempotent, diagnostics-rich, and security-aware maintenance
##############################################################################

LOGFILE="/var/log/maintenance.log"
ADMIN_USER="hhoyos"
ADMIN_PASS="P@ssw0rd"    # CHANGE IMMEDIATELY AFTER FIRST LOGIN!

echo "==== Maintenance started at $(date) ====" | tee -a "$LOGFILE"

##############################################################################
# Section: OS and Privilege Detection
##############################################################################
if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] Must run as root." | tee -a "$LOGFILE"; exit 1
fi
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS_NAME=$ID
    OS_VER=$VERSION_ID
else
    echo "[ERROR] Could not detect OS version." | tee -a "$LOGFILE"; exit 2
fi
echo "[*] Detected OS: $OS_NAME $OS_VER" | tee -a "$LOGFILE"
case "$OS_NAME-$OS_VER" in
    ubuntu-18.04|ubuntu-20.04|ubuntu-22.04|debian-10|debian-11) : ;;
    *) echo "[WARN] Unsupported OS: $OS_NAME $OS_VER. Exiting for safety." | tee -a "$LOGFILE"; exit 3 ;;
esac

##############################################################################
# Section: Time, Network, and System Health Checks
##############################################################################
echo "[*] Setting UTC timezone and NTP..." | tee -a "$LOGFILE"
timedatectl set-timezone UTC
timedatectl set-ntp true
systemctl restart systemd-timesyncd
timedatectl status | tee -a "$LOGFILE"

echo "[*] Network & DNS checks..." | tee -a "$LOGFILE"
ping -c 2 8.8.8.8 >/dev/null 2>&1 && echo "[OK] Network: Online" | tee -a "$LOGFILE" || echo "[WARN] Network: Offline." | tee -a "$LOGFILE"
host google.com >/dev/null 2>&1 && echo "[OK] DNS: Working" | tee -a "$LOGFILE" || echo "[WARN] DNS: Broken" | tee -a "$LOGFILE"

echo "[*] Memory, uptime, disk, swap checks..." | tee -a "$LOGFILE"
free -h | tee -a "$LOGFILE"
uptime | tee -a "$LOGFILE"
df -h | tee -a "$LOGFILE"
mem_total_mb=$(free -m | awk '/^Mem:/{print $2}')
swap_total_mb=$(free -m | awk '/^Swap:/{print $2}')
if (( mem_total_mb < 4096 && swap_total_mb < 512 )); then
  echo "[WARN] Low swap for low-memory VM (<4GB RAM, <512MB swap)." | tee -a "$LOGFILE"
fi

##############################################################################
# Section: APT Third-Party Repo Audit and Upgradable Packages Summary
##############################################################################
echo "[*] Auditing APT sources for third-party or external repositories..." | tee -a "$LOGFILE"
EXT_REPOS=$(grep -h ^deb /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null | grep -v 'ubuntu.com' | wc -l)
THIRD_PARTY_REPOS=$(grep -h ^deb /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null | grep -v 'ubuntu.com')
if (( EXT_REPOS > 0 )); then
  echo "[WARN] Detected $EXT_REPOS external (non-Ubuntu) APT repositories. Review sources in /etc/apt/sources.list.d/ for compatibility and security." | tee -a "$LOGFILE"
  echo "[INFO] List of detected third-party repositories:" | tee -a "$LOGFILE"
  echo "$THIRD_PARTY_REPOS" | tee -a "$LOGFILE"
fi

##############################################################################
# Section: SSH Server Installation and Root Login Hardening
##############################################################################
echo "[*] Checking for OpenSSH server and root login configuration..." | tee -a "$LOGFILE"

if ! dpkg -l | grep -qw openssh-server; then
  echo "[INFO] OpenSSH server not installed. Installing..." | tee -a "$LOGFILE"
  apt-get update -qq
  apt-get install -y openssh-server | tee -a "$LOGFILE"
  if [[ $? -ne 0 ]]; then
    echo "[ERROR] Failed to install openssh-server. Exiting for safety." | tee -a "$LOGFILE"
    exit 20
  fi
else
  echo "[INFO] OpenSSH server already installed." | tee -a "$LOGFILE"
fi

PERMIT_ROOT=$(grep -E "^\s*PermitRootLogin\s+yes" /etc/ssh/sshd_config)
if [[ -n "$PERMIT_ROOT" ]]; then
  echo "[INFO] Root SSH login is enabled. (Lab default, disable for production)" | tee -a "$LOGFILE"
  PERMIT_ROOT_STATE="ENABLED"
else
  echo "[WARN] Root SSH login is NOT enabled. (This is best for production, not lab automation)" | tee -a "$LOGFILE"
  PERMIT_ROOT_STATE="DISABLED"
fi

##############################################################################
# Section: Lab Admin User Creation and Sudo Setup
##############################################################################
echo "[*] Checking for admin user '$ADMIN_USER'..." | tee -a "$LOGFILE"
PW_CHANGED_MSG="OK"
if ! id -u "$ADMIN_USER" >/dev/null 2>&1; then
  echo "[INFO] User '$ADMIN_USER' does not exist. Creating with sudo privileges..." | tee -a "$LOGFILE"
  useradd -m -s /bin/bash "$ADMIN_USER"
  echo "$ADMIN_USER:$ADMIN_PASS" | chpasswd
  usermod -aG sudo "$ADMIN_USER"
  passwd -e "$ADMIN_USER"
  echo "[WARN] User '$ADMIN_USER' created with default password '$ADMIN_PASS'. CHANGE IMMEDIATELY." | tee -a "$LOGFILE"
  PW_CHANGED_MSG="DEFAULT"
else
  echo "[INFO] User '$ADMIN_USER' already exists. Ensuring sudo privileges..." | tee -a "$LOGFILE"
  usermod -aG sudo "$ADMIN_USER"
  PW_STATUS=$(sudo -lU "$ADMIN_USER" 2>&1)
  if echo "$PW_STATUS" | grep -q "(ALL : ALL) ALL"; then
    echo "[INFO] User '$ADMIN_USER' already has sudo privileges." | tee -a "$LOGFILE"
  else
    echo "[WARN] User '$ADMIN_USER' may not have correct sudo privileges! Check /etc/sudoers." | tee -a "$LOGFILE"
  fi
  PW_HASH=$(getent shadow "$ADMIN_USER" | cut -d: -f2)
  DEFAULT_HASH='$6$4t53xZBq$5GuIuXtRDF/48cjs0KkTkHuv9X7kODD9sdKQq1BUt9twY4wqDFXITqacDKSmrO4a2BU5kef3OYeANXKJKSkKV1'
  if [[ "$PW_HASH" == "$DEFAULT_HASH" ]]; then
    echo "[WARN] '$ADMIN_USER' is still using the default password! CHANGE IT IMMEDIATELY." | tee -a "$LOGFILE"
    PW_CHANGED_MSG="DEFAULT"
  fi
fi

##############################################################################
# Section: Package Maintenance, Security Patching, and Blocked Packages Report
##############################################################################
echo "[*] APT health and security updates..." | tee -a "$LOGFILE"
dpkg --configure -a 2>&1 | tee -a "$LOGFILE"
apt-get -f install -y | tee -a "$LOGFILE"
apt-get update -qq

# Show all upgradable packages, including those blocked by pinning or origin
UPGRADABLE_LIST=$(apt list --upgradable 2>/dev/null | grep -v 'Listing...')
echo "[INFO] Packages available for upgrade:" | tee -a "$LOGFILE"
echo "$UPGRADABLE_LIST" | tee -a "$LOGFILE"
UPGRADE_SUMMARY=$(echo "$UPGRADABLE_LIST" | wc -l)
apt-get install -y unattended-upgrades >/dev/null 2>&1
unattended-upgrade -d | tee -a "$LOGFILE"

##############################################################################
# Section: Safe Cleanup and System Pruning
##############################################################################
echo "[*] Performing safe cleanup and pruning..." | tee -a "$LOGFILE"
apt-mark hold openssh-server network-manager netplan.io systemd
apt-get autoremove --purge -y | tee -a "$LOGFILE"
apt-mark unhold openssh-server network-manager netplan.io systemd
current_kernel=$(uname -r)
old_kernels=$(dpkg --list | awk '/linux-image-[0-9]/{print $2}' | grep -v "$current_kernel")
if [[ -n "$old_kernels" ]]; then
  echo "[*] Removing old kernels: $old_kernels" | tee -a "$LOGFILE"
  apt-get purge -y $old_kernels | tee -a "$LOGFILE"
fi
apt-get clean | tee -a "$LOGFILE"
journalctl --vacuum-time=7d | tee -a "$LOGFILE"
find /var/log -type f \( -name "*.gz" -o -name "*.1" -o -name "*.old" -o -name "*.bak" -o -name "*.xz" -o -name "*.log" \) -mtime +7 -print -delete | tee -a "$LOGFILE"
find /var/crash -type f -mtime +14 -print -delete | tee -a "$LOGFILE"
find /var/cache/apt/archives -type f -mtime +7 -print -delete | tee -a "$LOGFILE"

##############################################################################
# Section: Self-Heal for Systemd
##############################################################################
echo "[*] Checking for failed systemd units..." | tee -a "$LOGFILE"
systemctl --failed | tee -a "$LOGFILE"
for unit in $(systemctl --failed --no-legend | awk '{print $1}'); do
  echo "Restarting $unit" | tee -a "$LOGFILE"
  systemctl restart "$unit"
done

##############################################################################
# Section: UFW/Firewall Setup (now always enabled)
##############################################################################
echo "[*] Enabling and configuring UFW firewall (lab-safe: allows SSH)..." | tee -a "$LOGFILE"
apt-get install -y ufw | tee -a "$LOGFILE"
ufw allow OpenSSH
ufw --force enable
ufw status verbose | tee -a "$LOGFILE"

##############################################################################
# Section: Post-Run Auditing and Reporting
##############################################################################
echo "[*] Top memory-using processes:" | tee -a "$LOGFILE"
ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 10 | tee -a "$LOGFILE"
echo "[*] Recent SSH logins:" | tee -a "$LOGFILE"
last -a | head -n 10 | tee -a "$LOGFILE"

##############################################################################
# Section: End-of-Run Safety and Troubleshooting Summary
##############################################################################
echo "==== Maintenance finished at $(date) ====" | tee -a "$LOGFILE"
echo "------------------------------------------------------------------------"
if [[ "$PW_CHANGED_MSG" == "DEFAULT" ]]; then
  echo -e "[ALERT] The '$ADMIN_USER' account is still using the DEFAULT PASSWORD. CHANGE IT NOW!\n"
fi
if (( UPGRADE_SUMMARY > 0 )); then
  echo "[INFO] $UPGRADE_SUMMARY package(s) are available for upgrade (not all may be security updates)."
  echo "[INFO] Some packages may be held back due to third-party repositories or pinning."
  echo "[INFO] To view all upgradable packages, run: sudo apt list --upgradable"
  echo "[INFO] To attempt a full upgrade (not recommended for production): sudo apt upgrade"
  if (( EXT_REPOS > 0 )); then
    echo "[INFO] Third-party repositories can interfere with unattended upgrades. Review sources in /etc/apt/sources.list.d/ and consider pinning or cleaning as needed."
    echo "[INFO] To see all repo configuration, run: grep ^deb /etc/apt/sources.list /etc/apt/sources.list.d/*"
  fi
fi
if [[ "$PERMIT_ROOT_STATE" == "ENABLED" ]]; then
  echo "[WARN] Root SSH login is enabled! Lock down to 'prohibit-password' for production use:"
  echo "       sudo sed -i 's/^PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config && sudo systemctl restart ssh"
fi
echo "[*] Review $LOGFILE for full run details, warnings, and summary."
echo "------------------------------------------------------------------------"
