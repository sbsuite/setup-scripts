    
#Find the MSI package that created with script and renaming it according to configuration, version etc.

$packageFullPath = Resolve-Path "$env:SETUP_PROJECT_PATH/**/$env:CONFIGURATION/*.msi"
$packageFullPathAsString = $packageFullPath.Path
$packageFileName= [System.IO.Path]::GetFileNameWithoutExtension($packageFullPathAsString )
$packageFolderPath = Split-Path -Path $packageFullPathAsString 
$targetName = "$($packageFileName).$($env:APP_VERSION).msi"
$targetFullPath = [System.IO.Path]::Combine($packageFolderPath,$targetName)

Move-Item $packageFullPathAsString $targetFullPath
Write-Host "Renaming $($packageFileName) and saving to: $($targetFullPath)" -ForegroundColor Green