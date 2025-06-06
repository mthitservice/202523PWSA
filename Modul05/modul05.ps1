# Laden der Config
$executionPath=split-path -parent $MyInvocation.MyCommand.Definition
$path="$executionPath\config.json" 
$config = Get-Content -Path $path |ConvertFrom-Json
$config.'smtp-server'