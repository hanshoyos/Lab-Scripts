# Bash Scripts

This folder contains Bash shell scripts for Linux system maintenance, environment auditing, and automation.  
**All scripts are provided as-is for lab, homelab, or learning use—**not intended for production systems.

## ⚠️ Disclaimer

> Use these scripts at your own risk.  
> Always review and understand any script before running it.  
> No warranty or support is provided.

## 📜 Available Scripts

### `ultimate-linux-maintenance.sh`
Performs comprehensive, unattended maintenance on Ubuntu/Debian systems:

- Cleans orphaned packages, logs, and old kernels
- Applies security updates via `unattended-upgrades`
- Validates SSH server configuration and UFW firewall status
- Optionally creates a default lab admin user (change password immediately)
- Detects third-party APT repositories and reports held packages
- Logs actions to `/var/log/maintenance.log`
- Idempotent and safe to rerun

### `guac_env_audit.sh`
Performs a pre-deployment audit of a Linux system intended to host Apache Guacamole:

- Verifies that the host is running **Ubuntu 20.04**
- Gathers system details: hostname, uptime, CPU, RAM, disk
- Audits all network interfaces, IP addresses, DNS, and routes
- Lists enabled services and checks for failed `systemd` units
- Confirms status of `guacd`, `tomcat9`, and Java (required by Guacamole)
- Lists open ports and UFW firewall state
- Logs all findings to `/var/log/guac_env_audit.log`

---

## 🔧 Usage Notes

- Run all scripts as `root` or using `sudo`.
- Review and edit top-level variables (e.g. default user credentials) before execution.
- Logs are written to `/var/log` for post-run analysis and troubleshooting.

---

For usage details, audit logic, or configuration instructions, refer to the inline comments in each script.
