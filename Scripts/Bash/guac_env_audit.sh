#!/bin/bash
##############################################################################
# Guacamole Environment Audit – guac_env_audit.sh
# Purpose: Audit and verify system readiness for Apache Guacamole deployment
# Maintainer: (Your Name)
# Version: 1.0
# Supported OS: Ubuntu 20.04
# WARNING: Logs full system info. Review before publishing or sharing logs.
##############################################################################

LOGFILE="/var/log/guac_env_audit.log"

echo "==== Guacamole Environment Audit started at $(date) ====" | tee "$LOGFILE"

##############################################################################
# Section: OS and Privilege Validation
##############################################################################
if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] This script must be run as root." | tee -a "$LOGFILE"; exit 1
fi

source /etc/os-release
if [[ "$ID" != "ubuntu" || "$VERSION_ID" != "20.04" ]]; then
  echo "[ERROR] This script is only supported on Ubuntu 20.04. Detected: $PRETTY_NAME" | tee -a "$LOGFILE"
  exit 2
fi
echo "[INFO] Detected Ubuntu 20.04 – proceeding..." | tee -a "$LOGFILE"

##############################################################################
# Section: Kernel, Hardware, and Host Metadata
##############################################################################
echo -e "\n[*] System Information:" | tee -a "$LOGFILE"
hostnamectl | tee -a "$LOGFILE"
uname -a | tee -a "$LOGFILE"
uptime | tee -a "$LOGFILE"
lscpu | grep -E 'Model name|CPU\(s\)|Socket|Thread' | tee -a "$LOGFILE"

##############################################################################
# Section: Network Interfaces, IPs, and Routes
##############################################################################
echo -e "\n[*] Network Interfaces and IP Addresses:" | tee -a "$LOGFILE"
ip addr show | tee -a "$LOGFILE"

echo -e "\n[*] Routing Table:" | tee -a "$LOGFILE"
ip route show | tee -a "$LOGFILE"

echo -e "\n[*] DNS Resolver Configuration:" | tee -a "$LOGFILE"
systemd-resolve --status 2>/dev/null | tee -a "$LOGFILE"
cat /etc/resolv.conf | tee -a "$LOGFILE"

##############################################################################
# Section: Firewall and Port Visibility
##############################################################################
echo -e "\n[*] UFW Firewall Status:" | tee -a "$LOGFILE"
ufw status verbose | tee -a "$LOGFILE"

echo -e "\n[*] Open TCP/UDP Ports:" | tee -a "$LOGFILE"
ss -tuln | tee -a "$LOGFILE"

##############################################################################
# Section: Memory, CPU Load, and Disk Usage
##############################################################################
echo -e "\n[*] Memory & Swap Status:" | tee -a "$LOGFILE"
free -h | tee -a "$LOGFILE"

echo -e "\n[*] CPU Load Averages:" | tee -a "$LOGFILE"
uptime | tee -a "$LOGFILE"

echo -e "\n[*] Disk Usage Summary:" | tee -a "$LOGFILE"
df -hT | tee -a "$LOGFILE"

##############################################################################
# Section: Java, Tomcat, and guacd Detection
##############################################################################
echo -e "\n[*] Java Version (required for Guacamole):" | tee -a "$LOGFILE"
java -version 2>&1 | tee -a "$LOGFILE"

echo -e "\n[*] Checking Tomcat installation (tomcat9 expected):" | tee -a "$LOGFILE"
dpkg -l | grep tomcat9 | tee -a "$LOGFILE"
systemctl status tomcat9 --no-pager | tee -a "$LOGFILE"

echo -e "\n[*] Checking guacd daemon status:" | tee -a "$LOGFILE"
dpkg -l | grep guacd | tee -a "$LOGFILE"
systemctl status guacd --no-pager | tee -a "$LOGFILE"

##############################################################################
# Section: Systemd and Service Audit
##############################################################################
echo -e "\n[*] Enabled Services (systemctl list-unit-files):" | tee -a "$LOGFILE"
systemctl list-unit-files --state=enabled | tee -a "$LOGFILE"

echo -e "\n[*] Failed Systemd Units:" | tee -a "$LOGFILE"
systemctl --failed | tee -a "$LOGFILE"

##############################################################################
# Section: Summary
##############################################################################
echo -e "\n==== Guacamole Environment Audit completed at $(date) ====" | tee -a "$LOGFILE"
echo "[*] Review the log at: $LOGFILE"
echo "[*] Ensure Java, Tomcat9, guacd are installed and running cleanly before continuing."
