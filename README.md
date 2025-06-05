# Linux Automation & Maintenance Scripts

Welcome to the **Scripts** directory.

This repository is a collection of modular scripts for Linux and Windows automation, system cleanup, and basic hardening.  
**These scripts are provided as-is for use in lab, homelab, or educational environments.**

## 📁 Folder Structure

- `Bash/` – Shell scripts for Linux maintenance and basic automation
- `PowerShell/` – PowerShell scripts (future: Windows or cross-platform)
- `Python/` – Python scripts (future: utilities, reporting, etc.)
- `Ansible/` – Ansible playbooks (planned)
- `Terraform/` – Terraform modules (planned)

## ⚠️ Disclaimer

> **Use these scripts at your own risk.**
>
> They are not designed, tested, or recommended for production environments.  
> No guarantees are provided—always review and understand any script before running it on your systems.  
> By using these scripts, you accept full responsibility for any changes, data loss, or disruptions that may occur.

## 🛠️ How To Use

### 1. Clone this repository

```
git clone https://github.com/hanshoyos/Lab-Scripts.git
cd Lab-Scripts/Scripts
```

### 2. Navigate to a script subfolder

```
cd Bash
cd PowerShell
cd Python
cd Ansible
cd Terraform
```

### 3. Open and review scripts in your preferred editor

### 4. Run a script

#### Bash / Python

```
chmod +x scriptname.sh
sudo ./scriptname.sh
```

#### PowerShell

```
pwsh -File .\scriptname.ps1
```

#### Ansible

```
ansible-playbook playbook.yml -i inventory_file
```

#### Terraform

```
terraform init
terraform plan
terraform apply
```

### 5. After running

Review any logs, output, or summaries for next steps or cleanup.

---

## 🔄 Keeping Your Repo Updated

To refresh your local copy with the latest updates from GitHub:

```
cd Lab-Scripts
git fetch origin
git pull origin main
```

If you made local changes and want to discard them:

```
git reset --hard origin/main
git clean -fd
```

> ⚠️ **Warning:** This will delete any uncommitted changes. Make backups or use a separate branch for custom edits.

---

> **Always review scripts before running and use at your own risk!**
