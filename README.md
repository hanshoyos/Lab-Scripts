# Linux Automation & Maintenance Scripts

Welcome to the **Scripts** directory.

This repository is a collection of modular scripts for Linux and Windows automation, system cleanup, and basic hardening.  
**These scripts are provided as-is for use in lab, homelab, or educational environments.**

## 📁 Folder Structure

- `Bash/` – Shell scripts for Linux maintenance and basic automation
- `PowerShell/` – PowerShell scripts (future: Windows or cross-platform)
- `Python/` – Python scripts (future: utilities, reporting, etc.)

## ⚠️ Disclaimer

> **Use these scripts at your own risk.**
>
> They are not designed, tested, or recommended for production environments.  
> No guarantees are provided—always review and understand any script before running it on your systems.  
> By using these scripts, you accept full responsibility for any changes, data loss, or disruptions that may occur.

## 🛠️ How To Use

1. Browse to the language-specific subfolder for available scripts.
2. Each subfolder contains its own README with brief descriptions and usage notes for each script.
3. **Review all scripts and update variables as needed before running.**

---

> **Note:**  
> These scripts are for learning, experimentation, and lab automation.  
> Contributions are welcome—just keep safety, clarity, and documentation in mind!

---

## 🏁 Quick Start Guide

1. **Clone this repository:**
    ```sh
    git clone https://github.com/hanshoyos/Lab-Scripts.git
    cd Lab-Scripts/Scripts
    ```

2. **Navigate to a script subfolder:**
    ```sh
    cd Bash        # Bash/Shell scripts
    cd PowerShell  # PowerShell scripts
    cd Python      # Python scripts
    cd Ansible     # Ansible playbooks
    cd Terraform   # Terraform modules
    ```

3. **Open and review scripts in your preferred editor.**

4. **To run a script:**
    - **Bash/Python:**  
      Make executable if needed, then run (use `sudo` if required):
      ```sh
      chmod +x scriptname.sh
      sudo ./scriptname.sh
      ```
    - **PowerShell:**
      ```powershell
      pwsh -File .\scriptname.ps1
      ```
    - **Ansible:**
      ```sh
      ansible-playbook playbook.yml -i inventory_file
      ```
    - **Terraform:**
      ```sh
      terraform init
      terraform plan
      terraform apply
      ```

5. **After running,** review any output, log files, or summary notes for results and next steps.

---

> **Always review scripts before running and use at your own risk!**

---
