param(
	[Switch] $Recurse,
	[String] $Path
)

if ([String]::IsNullOrEmpty($Path)) {
	Write-Host "[fs.filetypepresence] Usage: fs.filetypepresence.ps1 [-Path] <PATH> [-Recurse]"
	exit 1
}

if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
	Write-Host "[fs.filetypepresence] The given path parameter [$Path] does not exist or is not a valid path"
	exit 2
}

$Path = Resolve-Path -LiteralPath $Path
if ($Recurse) {
	$Full = Get-ChildItem -LiteralPath $Path -Recurse -Force -File
} else {
	$Full = Get-ChildItem -LiteralPath $Path -Force -File
}
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
Write-Host "Total Files: $Size"
Write-Host "--------------------------------"
