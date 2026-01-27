# WSL Configuration Files

## Files

| File | Location | Description |
|------|----------|-------------|
| `wsl.conf` | `/etc/wsl.conf` (inside WSL) | Per-distro settings |
| `.wslconfig` | `%USERPROFILE%\.wslconfig` (Windows) | Global WSL2 settings |

## Installation

**wsl.conf (inside WSL):**
```bash
sudo cp ~/.dotfiles/wsl/wsl.conf /etc/wsl.conf
```

**.wslconfig (from PowerShell):**
```powershell
copy \\wsl$\Ubuntu\home\rich\.dotfiles\wsl\.wslconfig $env:USERPROFILE\.wslconfig
```

**Then restart WSL (from PowerShell):**
```powershell
wsl --shutdown
```

## Your P15 Setup Notes

- Dual NVMe drives
- Intel i7 10th Gen
- Running VMs alongside WSL
- Memory limit set to 8GB (adjust in .wslconfig if needed)
