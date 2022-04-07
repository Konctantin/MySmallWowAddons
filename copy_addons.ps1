$scriptPath = split-path -parent $MyInvocation.MyCommand.ScriptBlock.File
$WOW_INSTALL_KEY = "HKLM:\SOFTWARE\WOW6432Node\Blizzard Entertainment\World of Warcraft"
$WOW_DIR = (Get-ItemProperty -Path $WOW_INSTALL_KEY -Name "InstallPath").InstallPath
$WOW_DIR = (Get-Item $WOW_DIR).Parent.FullName

$ADDON_LIST = Get-ChildItem -Path $scriptPath -Directory -Force -ErrorAction SilentlyContinue

Function CopyAddon($addonFolder){
    $addonName = $addonFolder.Name;
    $addonSrcFullPath = $addonFolder.FullName
	$addonDstFullPath = Join-Path -Path $WOW_DIR -ChildPath "_retail_\Interface\AddOns\$addonName"

	Write-Output "Cleanup addon path: $addonDstFullPath"
	Remove-Item -LiteralPath $addonDstFullPath -Force -Recurse

	Write-Output "Copy addon from $addonSrcFullPath to $addonDstFullPath"
	Copy-Item -Path $addonSrcFullPath -Filter "*.*" -Recurse -Destination $addonDstFullPath -Container
}

foreach ($addonFolder in $ADDON_LIST) {
	CopyAddon $addonFolder
}
