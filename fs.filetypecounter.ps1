[CmdletBinding(PositionalBinding=$false)]
param
(
	[Parameter()][switch] $Recurse,
	[Parameter()][switch] $PassObject,
	[Parameter(Position=0)][string] $Path = $PWD
)

if (($Path -eq '--help' -or $Path -eq '?') -or [string]::IsNullOrWhiteSpace($Path)) {
	Write-Output "[fs.filetypecounter] Usage: fs.filetypecounter.ps1 [-Path] <PATH> [-Recurse] [-PassObject]"
	exit 0
}
if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
	Write-Output "[fs.filetypecounter] The given path parameter ""$Path"" does not exist or is not a valid path!"
	exit 1
}

$Path = Convert-Path -LiteralPath $Path

if ($Recurse) {
	$Full = Get-ChildItem $Path -Recurse -Force -File
} 
else {
	$Full = Get-ChildItem $Path -Force -File
}

$Size = ($Full | Measure-Object).Count

$Exts = [System.Collections.Generic.List[System.String]]::new()
$Outp = [System.Collections.Generic.List[System.Object]]::new()

foreach ($Item in $Full) {
	if (-not ($Exts.Contains($Item.Extension))) {
		$Exts.Add($Item.Extension)
	}
}
foreach ($Item in $Exts) {
	$Outp.Add([pscustomobject]@{Extension = $Item; Count = [UInt64]0})
}

if ($Exts.Contains([string]::Empty)) {
	$Outp[$Exts.IndexOf([string]::Empty)].Extension = '(No Extension)'
}

for ($i = 0; $i -lt $Size; $i++) {
	$cext = $Full[$i].Extension
	$aidx = $Exts.IndexOf($cext)
	$cout = $Outp[$aidx].Count
	$Outp[$aidx].Count = $cout++
}

if ($PassObject) {
	return $Outp
}
else {
	Write-Output '┌────────────────────────────────┬─────────────────────────────────┐'
	Write-Output '│      Filetype (Extension)      │             Amount              │'
	Write-Output '├────────────────────────────────┼─────────────────────────────────┤'
	foreach ($Entry in $Outp) {
		$lstr = [string]::Concat('│', $Entry.Extension.PadLeft(18), '│'.PadLeft(15))
		$rstr = [string]::Concat(([string]$Entry.Count).PadLeft(18), '│'.PadLeft(16))
		$ostr = [string]::Concat($lstr, $rstr)
		Write-Output $ostr
	}
	$tstr = [string]::Concat('│', "Total Files: $Size".PadLeft(24), '│'.PadLeft(9))
	Write-Output '├────────────────────────────────┼─────────────────────────────────┘'
	Write-Output $tstr
	Write-Output '└────────────────────────────────┘'
}

