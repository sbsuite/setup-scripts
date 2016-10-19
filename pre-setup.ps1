$fragmentsPath = "$env:SETUP_PROJECT_PATH/fragments"
$fragments = Get-ChildItem $env:APPVEYOR_BUILD_FOLDER/packages -Filter *.wxs -Recurse | %{$_.FullName} 
$count = @($fragments).count;
Write-Host "Copying $($count) *.wxs files to: $($fragmentsPath)" -ForegroundColor Green
foreach($fragment in $fragments)
{
    Copy-Item $fragment  $fragmentsPath
}