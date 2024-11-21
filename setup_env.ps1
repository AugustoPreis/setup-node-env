<#
  .SYNOPSIS
    Download and install tools for development environment setup.

  .DESCRIPTION
    This script downloads and installs the following development tools:
    - Chocolatey
    - Node.js LTS
    - Git
    - Docker
    - Visual Studio Code
    - DBeaver

    Node.js development environment setup script.
    If you want to install other tools, change the $packages array.

  .NOTES
    File Name      : setup_env.ps1
    Author         : Augusto Preis Tomasi
    Prerequisite   : PowerShell 5.1 or later
#>

#Test if the current user is an administrator
function Test-Admin {
  #Get the current principal and its security identifier (SID)
  $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

  #Check if the current principal is in the Administrators group
  return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

#Install a package using Chocolatey
function Install {
  param(
    #The name of the package to install
    [string]$name
  )
  $separator = "------------------------------------------------"

  Write-Host `n$separator -ForegroundColor Yellow
  Write-Host "Installing $name..." -ForegroundColor Yellow
  Write-Host $separator`n -ForegroundColor Yellow

  #Install the package
  choco install $name -y

  #Check if the installation was successful
  #If not, ask the user if they want to continue
  if ($LASTEXITCODE -ne 0) {
    $continue = Read-Host "Do you want to continue? ([Y]es/[N]o)"
    
    $continue = $continue.ToLower()

    if ($continue -ne "y") {
      exit
    }
  }
}

## Main script ##

if (-not (Test-Admin)) {
  Write-Host "Please run this script as an administrator." -ForegroundColor Red
  exit
}

#Verify if Chocolatey is installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
  #If Chocolatey is not installed, install it

  Write-Host "Installing Chocolatey..." -ForegroundColor Yellow

  #Set the execution policy to bypass
  #The "-Scope Process" parameter ensures that the execution policy is only changed for the current session
  #The "-Force" parameter suppresses the confirmation prompt
  Set-ExecutionPolicy Bypass -Scope Process -Force

  #Config TLS 1.2 protocol for Chocolatey installation
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

  #Download and install Chocolatey
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))

  Write-Host "Chocolatey installed." -ForegroundColor Green
}

<#
  List of packages to install

  See https://chocolatey.org/packages for a list of available packages
#>
$packages = @(
  "nodejs-lts",
  "git",
  "docker",
  "vscode",
  "dbeaver"
)

foreach ($package in $packages) {
  Install $package
}