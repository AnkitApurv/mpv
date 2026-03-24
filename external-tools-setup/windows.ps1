# install-tools.ps1

# -----------------------------
# Install ffmpeg via winget
# -----------------------------
winget install --id Gyan.FFmpeg --accept-package-agreements --accept-source-agreements

# -----------------------------
# Install Python (if needed)
# -----------------------------
winget install --id Python --accept-package-agreements --accept-source-agreements

# -----------------------------
# Install subliminal
# -----------------------------
pip install subliminal

# -----------------------------
# Install alass (ZIP method)
# -----------------------------
$alassUrl = "https://github.com/kaegi/alass/releases/download/v2.0.0/alass-windows64.zip"
$tempZip = "$env:TEMP\alass.zip"
$tempExtract = "$env:TEMP\alass_extract"
$installDir = "$env:USERPROFILE\bin"

# Create directories
New-Item -ItemType Directory -Force -Path $tempExtract | Out-Null
New-Item -ItemType Directory -Force -Path $installDir | Out-Null

# Download ZIP
Invoke-WebRequest $alassUrl -OutFile $tempZip

# Extract ZIP
Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

# Find alass-cli.exe inside extracted folder
$alassExe = Get-ChildItem -Path $tempExtract -Recurse -Filter "alass-cli.exe" | Select-Object -First 1

if ($alassExe -eq $null) {
    Write-Error "alass-cli.exe not found in archive!"
    exit 1
}

# Move to install directory
Copy-Item $alassExe.FullName -Destination "$installDir\alass-cli.exe" -Force

# -----------------------------
# Add to PATH (user level)
# -----------------------------
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$currentPath;$installDir",
        "User"
    )
}

# -----------------------------
# Cleanup
# -----------------------------
Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Installation complete. Restart terminal to refresh PATH."
