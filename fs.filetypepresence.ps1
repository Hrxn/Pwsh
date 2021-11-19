if ($args[0] -eq $null) {
	Write-Host "[fs.filetypepresence] Usage: fs.filetypepresence.ps1 <PATH>"
	exit 1
}

if (-not (Test-Path -LiteralPath $args[0] -PathType Container)) {
	Write-Host "[fs.filetypepresence] Given <PATH> does not exist or is not a valid path"
	exit 2
}

$Path = Resolve-Path -LiteralPath $args[0]
$Full = Get-ChildItem -LiteralPath $Path -Recurse -Force -File
$Size = $Full.Count
$Exts = [System.Collections.Generic.List[String]]::new()

foreach ($Item in $Full) {
	if (-not ($Exts.Contains($Item.Extension))) {
		$Exts.Add($Item.Extension)
	}
}

if ($Exts.Contains([String]::Empty)) {
	$Exts[$Exts.IndexOf([String]::Empty)] = '(No Extension)'
}

Write-Host "-- The following File Types / File Extensions have been found --"
foreach ($Type in $Exts) {
	Write-Host $Type
}
Write-Host "----------------------------------------------------------------"
