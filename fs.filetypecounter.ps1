param(
	[String] $Path,
	[Switch] $Recurse,
	[Switch] $PassObject
)

if ([String]::IsNullOrEmpty($Path)) {
	Write-Host "[fs.filetypecounter] Usage: fs.filetypecounter.ps1 [-Path] <PATH> [-Recurse] [-PassObject]"
	exit 1
}

if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
	Write-Host "[fs.filetypecounter] The given path parameter [$Path] does not exist or is not a valid path"
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

$Outp = [System.Collections.Generic.List[PSObject]]::new()

foreach ($Item in $Exts) {
	$Outp.Add([PSCustomObject]@{Extension = $Item; Count = 0})
}

if ($Exts.Contains([String]::Empty)) {
	$Outp[$Exts.IndexOf([String]::Empty)].Extension = '---'
}

for ($i = 0; $i -lt $Size; $i++) {
	$cext = $Full[$i].Extension
	$aidx = $Exts.IndexOf($cext)
	$cout = $Outp[$aidx].Count
	$Outp[$aidx].Count = $cout + 1
}

if ($PassObject) {
	return $Outp
} else {
	Write-Host "+--------------------------------+--------------------------------+"
	Write-Host "|      Filetype (Extension)      |             Amount             |"
	Write-Host "+--------------------------------+--------------------------------+"
	$tstr = [String]::Concat("|", "Total Files: $Size".PadLeft(25), "|".PadLeft(8))
	foreach ($Entry in $Outp) {
		$lstr = [String]::Concat("|", $Entry.Extension.PadLeft(18), "|".PadLeft(15))
		$rstr = [String]::Concat(([String]$Entry.Count).PadLeft(18), "|".PadLeft(15))
		$ostr = [String]::Concat($lstr, $rstr)
		Write-Host $ostr
	}
	Write-Host "+--------------------------------+--------------------------------+"
	Write-Host $tstr
	Write-Host "+--------------------------------+"
}
