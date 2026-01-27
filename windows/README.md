# Windows Configuration Files

## What to Save

| Config | Location | Description |
|--------|----------|-------------|
| PowerShell Profile | `$PROFILE` | Your PS aliases, functions, prompt |
| Windows Terminal | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json` | Terminal themes, keybindings |
| VS Code | `%APPDATA%\Code\User\settings.json` | Editor settings |
| VS Code Keybindings | `%APPDATA%\Code\User\keybindings.json` | Custom shortcuts |
| Git Config | `%USERPROFILE%\.gitconfig` | Git settings |
| SSH Config | `%USERPROFILE%\.ssh\config` | SSH hosts |

## Quick Collection

Run the collector script from PowerShell:
```powershell
# From WSL, access this script:
powershell.exe -File "\\wsl$\Ubuntu\home\rich\.dotfiles\windows\collect-windows-configs.ps1"

# Or copy it to Windows and run:
.\collect-windows-configs.ps1
```

## Manual Collection

```powershell
# PowerShell profile
Copy-Item $PROFILE ~\.dotfiles\windows\Microsoft.PowerShell_profile.ps1

# Windows Terminal
Copy-Item "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" ~\.dotfiles\windows\windows-terminal.json

# VS Code
Copy-Item "$env:APPDATA\Code\User\settings.json" ~\.dotfiles\windows\vscode-settings.json
Copy-Item "$env:APPDATA\Code\User\keybindings.json" ~\.dotfiles\windows\vscode-keybindings.json

# Git config
Copy-Item ~\.gitconfig ~\.dotfiles\windows\gitconfig.windows
```

## Restore on New Machine

```powershell
# PowerShell profile
Copy-Item ~\.dotfiles\windows\Microsoft.PowerShell_profile.ps1 $PROFILE

# Windows Terminal
Copy-Item ~\.dotfiles\windows\windows-terminal.json "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# VS Code
Copy-Item ~\.dotfiles\windows\vscode-settings.json "$env:APPDATA\Code\User\settings.json"
```
