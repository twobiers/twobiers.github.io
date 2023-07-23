+++ 
draft = false
title = "SSH and GPG Relay inside WSL2 with systemd boot"
issueId = 3
+++

In this post I will explain how I'm using the Windows OpenSSH and Gpg4Win agents inside WSL2 with systemd.
This post is not explained in detail and serves mainly as a reference manual for future setups.

Download [npiperelay](https://github.com/jstarks/npiperelay) and [wsl-ssh-pageant](https://github.com/benpye/wsl-ssh-pageant).
Place both in a suitable directory on the windows side. I created `C:\tools` for that purpose.
Configure wsl-ssh-pageant for autostart. I chose a simple shortcut in the startup directory for that.
It should be started like this: `wsl-ssh-pageant-amd64-gui.exe -force -systray -verbose -wsl C:\tools\wsl-ssh-pageant\wsl-ssh-agent.sock -winssh winssh-pageant`

If you like to, you can execute the following PowerShell Script Which should configure the whole Windows side of things.
```ps1
# Create Shortcut to wsl-ssh-pageant in startup directory
$WshShell = New-Object -ComObject WScript.Shell
$pageantDir = "C:\tools\wsl-ssh-pageant"
$pageantPath = "$pageantDir\wsl-ssh-pageant-amd64-gui.exe"
$pageantSockPath = "$pageantDir\wsl-ssh-agent.sock"
$pageantPipeName = "winssh-pageant"
$autostartDir = "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
$npiperelayDir = "C:\tools\npiperelay"
$npiperelayPath = "$npiperelayDir\npiperelay.exe"

# Download and save wsl-ssh-pageant in tools directory
If (!(Test-Path $pageantDir)) {
	New-Item -ItemType Directory -Force -Path $pageantDir
}
Invoke-WebRequest -Uri "https://github.com/benpye/wsl-ssh-pageant/releases/download/20201121.2/wsl-ssh-pageant-amd64-gui.exe" -OutFile $pageantPath

# Download and save npiperelay in tools directory
If (!(Test-Path $npiperelayDir)) {
	New-Item -ItemType Directory -Force -Path $npiperelayDir
}
Invoke-WebRequest -Uri "https://github.com/NZSmartie/npiperelay/releases/download/v0.1/npiperelay.exe" -OutFile $npiperelayPath

# Create a startup shortcut for wsl-ssh-pageant
$Shortcut = $WshShell.CreateShortcut("$autostartDir\start-wsl-pageant.lnk")
$Shortcut.TargetPath = $pageantPath
$Shortcut.Arguments = "-force -systray -verbose -wsl $pageantSockPath -winssh $pageantPipeName"
$Shortcut.Save()

# Create a startup script for the gpg-agent
Write-Output "PowerShell.exe -WindowStyle Hidden -Command 'gpg-connect-agent /bye'" | Out-File "$autostartDir/start-gpg-connect-agent.bat"

```

You might also want to set additional environment variables:
```ps1
[Environment]::SetEnvironmentVariable("GIT_SSH", "C:\Windows\system32\OpenSSH\ssh.exe", 'Machine')
[Environment]::SetEnvironmentVariable("SSH_AUTH_SOCK", "\\.\pipe\$pageantPipeName", 'Machine')
```

In WSL, create two systemd units in `~/.config/systemd/user`.
`gpg.service`:
```ini
[Unit]
Description=GPG Relay

[Service]
ExecStartPre=/bin/rm -f /home/tobi/.gnupg/S.gpg-agent
ExecStart=/usr/bin/socat "UNIX-LISTEN:/home/tobi/.gnupg/S.gpg-agent,fork,unlink-close,unlink-early" EXEC:'/mnt/c/tools/npiperelay/npiperelay.exe -ei -ep -s -a "C:/Users/tobia/AppData/Local/gnupg/S.gpg-agent"',nofork
ExecStartPost=/bin/bash -c 'mkdir -p /run/user/1000/gnupg && /usr/bin/ln -s /home/tobi/.gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent'

[Install]
WantedBy=default.target
```

`ssh.service`:
```ini
[Unit]
Description=SSH Relay

[Service]
ExecStartPre=/bin/rm -f /home/tobi/.ssh/agent.sock
ExecStart=/usr/bin/socat "UNIX-LISTEN:/home/tobi/.ssh/agent.sock,fork,unlink-close,unlink-early" EXEC:"/mnt/c/tools/npiperelay/npiperelay.exe //./pipe/winssh-pageant",nofork

[Install]
WantedBy=default.target
```
Enable and start the units:
```sh
systemctl --user enable ssh.service 
systemctl --user enable gpg.service
systemctl --user start ssh 
systemctl --user start gpg
```
You might also need to disable default gpg sockets:
```sh
sudo systemctl disable --global gpg-agent.socket
sudo systemctl disable --global gpg-agent-extra.socket
sudo systemctl disable --global gpg-agent-ssh.socket
sudo systemctl disable --global gpg-agent-browser.socket
sudo systemctl disable --global dirmngr.socket
```
Now export environment variables in your `~/.bashrc`:
```sh
export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
export GPG_AGENT_SOCK=$HOME/.gnupg/S.gpg-agent
```
After rebooting the WSL distribution using `wsl --shutdown` on the windows side, it should work.