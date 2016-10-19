$fragmentsPath = "$env:APPVEYOR_BUILD_FOLDER\setup\$env:SETUP_PROJECT_NAME\fragments"
$fragments = Get-ChildItem $env:APPVEYOR_BUILD_FOLDER\packages -Filter *.wxs -Recurse | %{$_.FullName} 
Write-Host "Copying ($($fragments.Length)) *.wxs files to: $($fragmentsPaths)"
foreach($fragment in $fragments)
{
    Copy-Item $fragment  $fragmentsPath
}