# Collect Windows configs for dotfiles repo
# Run from PowerShell (as your user, not admin)

$dotfilesDir = "$env:USERPROFILE\.dotfiles\windows"

# If running from WSL clone, adjust path
if (-not (Test-Path $dotfilesDir)) {
    $dotfilesDir = "\\wsl$\Ubuntu\home\rich\.dotfiles\windows"
}

if (-not (Test-Path $dotfilesDir)) {
    Write-Host "Creating dotfiles windows directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $dotfilesDir -Force | Out-Null
}

Write-Host "=== Windows Config Collector ===" -ForegroundColor Cyan
Write-Host "Saving to: $dotfilesDir" -ForegroundColor Gray
Write-Host ""

function Copy-ConfigIfExists {
    param($Source, $DestName, $Description)

    if (Test-Path $Source) {
        Copy-Item $Source "$dotfilesDir\$DestName" -Force
        Write-Host "[OK] $Description" -ForegroundColor Green
    } else {
        Write-Host "[--] $Description not found" -ForegroundColor DarkGray
    }
}

# PowerShell Profile
Write-Host "`n--- PowerShell ---" -ForegroundColor Yellow
Copy-ConfigIfExists $PROFILE "Microsoft.PowerShell_profile.ps1" "PowerShell Profile"

# PowerShell Core profile (if different)
$pwshProfile = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
Copy-ConfigIfExists $pwshProfile "PowerShell_profile.ps1" "PowerShell Core Profile"

# Windows Terminal
Write-Host "`n--- Windows Terminal ---" -ForegroundColor Yellow
$wtPaths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
)
foreach ($wt in $wtPaths) {
    if (Test-Path $wt) {
        Copy-ConfigIfExists $wt "windows-terminal.json" "Windows Terminal Settings"
        break
    }
}

# VS Code
Write-Host "`n--- VS Code ---" -ForegroundColor Yellow
Copy-ConfigIfExists "$env:APPDATA\Code\User\settings.json" "vscode-settings.json" "VS Code Settings"
Copy-ConfigIfExists "$env:APPDATA\Code\User\keybindings.json" "vscode-keybindings.json" "VS Code Keybindings"

# Get extensions list
if (Get-Command code -ErrorAction SilentlyContinue) {
    code --list-extensions | Out-File "$dotfilesDir\vscode-extensions.txt" -Encoding UTF8
    Write-Host "[OK] VS Code Extensions List" -ForegroundColor Green
}

# Git
Write-Host "`n--- Git ---" -ForegroundColor Yellow
Copy-ConfigIfExists "$env:USERPROFILE\.gitconfig" "gitconfig.windows" "Git Config"
Copy-ConfigIfExists "$env:USERPROFILE\.gitignore_global" "gitignore_global.windows" "Git Global Ignore"

# SSH
Write-Host "`n--- SSH ---" -ForegroundColor Yellow
Copy-ConfigIfExists "$env:USERPROFILE\.ssh\config" "ssh-config" "SSH Config"
Write-Host "   (Remember: NEVER commit private keys!)" -ForegroundColor DarkYellow

# npm
Write-Host "`n--- Node/npm ---" -ForegroundColor Yellow
Copy-ConfigIfExists "$env:USERPROFILE\.npmrc" "npmrc" "npm Config"

# Starship prompt
Write-Host "`n--- Starship ---" -ForegroundColor Yellow
Copy-ConfigIfExists "$env:USERPROFILE\.config\starship.toml" "starship.toml" "Starship Config"

# Oh My Posh (if used)
Write-Host "`n--- Oh My Posh ---" -ForegroundColor Yellow
$ompThemes = Get-ChildItem "$env:USERPROFILE\*.omp.json" -ErrorAction SilentlyContinue
if ($ompThemes) {
    foreach ($theme in $ompThemes) {
        Copy-Item $theme.FullName "$dotfilesDir\$($theme.Name)" -Force
        Write-Host "[OK] Oh My Posh theme: $($theme.Name)" -ForegroundColor Green
    }
}

# scoop (package manager) export
Write-Host "`n--- Scoop ---" -ForegroundColor Yellow
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    scoop export | Out-File "$dotfilesDir\scoop-packages.txt" -Encoding UTF8
    Write-Host "[OK] Scoop packages list" -ForegroundColor Green
}

# winget export
Write-Host "`n--- Winget ---" -ForegroundColor Yellow
if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget export -o "$dotfilesDir\winget-packages.json" 2>$null
    if (Test-Path "$dotfilesDir\winget-packages.json") {
        Write-Host "[OK] Winget packages list" -ForegroundColor Green
    }
}

Write-Host "`n=== Collection Complete ===" -ForegroundColor Cyan
Write-Host "`nFiles saved to: $dotfilesDir" -ForegroundColor Gray
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  cd to your dotfiles repo and run:"
Write-Host "  git add windows/"
Write-Host "  git commit -m 'Add Windows configs'"
Write-Host "  git push"
