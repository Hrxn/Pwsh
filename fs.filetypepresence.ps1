[CmdletBinding(PositionalBinding=$false)]
param
(
	[Parameter()][switch] $Recurse,
	[Parameter(Position=0)][string] $Path = $PWD
)

if (($Path -eq '--help' -or $Path -eq '?') -or [string]::IsNullOrWhiteSpace($Path)) {
	Write-Output "[fs.filetypepresence] Usage: fs.filetypepresence.ps1 [-Path] <PATH> [-Recurse]"
	exit 0
}
if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
	Write-Output "[fs.filetypepresence] The given path parameter ""$Path"" does not exist or is not a valid path!"
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

foreach ($Item in $Full) {
	if (-not ($Exts.Contains($Item.Extension))) {
		$Exts.Add($Item.Extension)
	}
}

if ($Exts.Contains([string]::Empty)) {
	$Exts[$Exts.IndexOf([string]::Empty)] = '(No Extension)'
}

[System.Console]::WriteLine('────────────────────────────────────────────────────────────────')
[System.Console]::WriteLine('── The following File Types / File Extensions have been found ──')
[System.Console]::WriteLine('────────────────────────────────────────────────────────────────')
foreach ($Type in $Exts) {
	[System.Console]::WriteLine('    ' + $Type)
}
[System.Console]::WriteLine('────────────────────────────────────────────────────────────────')
[System.Console]::WriteLine("Total Files: $Size")
[System.Console]::WriteLine('───────────────────────────────')

