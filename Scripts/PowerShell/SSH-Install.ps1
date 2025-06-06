# Install OpenSSH Server if not already present
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start the OpenSSH SSH Server service
Start-Service sshd

# Set the SSH Server service to start automatically with Windows
Set-Service -Name sshd -StartupType 'Automatic'

# Allow SSH in Windows Firewall
if (-not (Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' `
        -DisplayName 'OpenSSH Server (sshd)' `
        -Enabled True `
        -Direction Inbound `
        -Protocol TCP `
        -Action Allow `
        -LocalPort 22
}

Write-Host "OpenSSH Server installation and configuration complete."
