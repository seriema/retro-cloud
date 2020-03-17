# Abort on error
$ErrorActionPreference = "Stop"

###################################
# Uninstall the Azure PowerShell module
# https://docs.microsoft.com/en-us/powershell/azure/uninstall-az-ps?view=azps-3.2.0

function Uninstall-AllModules {
  param(
    [Parameter(Mandatory=$true)]
    [string]$TargetModule,

    [Parameter(Mandatory=$true)]
    [string]$Version,

    [switch]$Force,

    [switch]$WhatIf
  )

  $AllModules = @()

  'Creating list of dependencies...'
  $target = Find-Module $TargetModule -RequiredVersion $version
  $target.Dependencies | ForEach-Object {
      $AllModules += New-Object -TypeName psobject -Property @{name=$_.name; version=$_.requiredVersion}
  }
  $AllModules += New-Object -TypeName psobject -Property @{name=$TargetModule; version=$Version}

  foreach ($module in $AllModules) {
    Write-Host ('Uninstalling {0} version {1}...' -f $module.name,$module.version)
    try {
      Uninstall-Module -Name $module.name -RequiredVersion $module.version -Force:$Force -ErrorAction Stop -WhatIf:$WhatIf
    } catch {
      Write-Host ("`t" + $_.Exception.Message)
    }
  }
}

# Uninstall all versions
$versions = (Get-InstalledModule -Name Az -AllVersions | Select-Object Version)
$versions | foreach { Uninstall-AllModules -TargetModule Az -Version ($_.Version) -Force }
