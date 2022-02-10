<#
.SYNOPSIS
Plays the media files in a given directory with mpv.

.DESCRIPTION
Simple script utilizing mpv to play media (video) files in a specified directory.

Dependencies:
	- mpv (https://mpv.io/)

.PARAMETER Path
Specifies the path to the directory containing the media files you want to play.
Uses the current working location as default if no path is specified.

.PARAMETER Fullscreen
Switch to run mpv with the fullscreen flag set.
Be aware that this can be overridden, depending on the 'Options' parameter.

.PARAMETER Options
A collection of string values describing the command-line options that are passed on to mpv.

.PARAMETER Random
Switch to play the media files in randomized order.
Uses the standard alphanumeric sorting by default, as is.

.EXAMPLE
mp.playdir

.EXAMPLE
mp.playdir -Options saturation=28, volume=50

.EXAMPLE
mp.playdir -Path .\Films -Full -Random

.INPUTS
None. You cannot pipe objects to mp.playdir.ps1.

.OUTPUTS
None. mp.playdir.ps1 does not generate any output.

.LINK
https://github.com/Hrxn/pwsh
#>

#Requires -Version 7.1

param (
	[Parameter()][string] $Path = $PWD.ToString(),
	[Parameter()][switch] $Fullscreen = $false,
	[Parameter()][switch] $Random = $false,
	[Parameter(ValueFromRemainingArguments)][string[]] $Options
)

if ($PWD.Provider.Name -cne 'FileSystem') {
	Write-Host '[mp.playdir] : Error -> The current working directory is not a valid path in a filesystem!' -ForegroundColor 'Red'
	exit 255
}
if ($null -eq (Get-Command -Name 'mpv' -ErrorAction 'Ignore')) {
	Write-Host '[mp.playdir] : Error -> Dependency Error: Missing dependency: mpv!' -ForegroundColor 'DarkRed'
	exit 254
}
if ($Path -eq '--help' -or $Path -eq '?') {
	Write-Host '[mp.playdir] Usage: mp.playdir.ps1 [-Path] [<PATH>] [-Fullscreen] [-Options] [<MPV OPTIONS>] [-Random]'
	exit 0
}
if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
	Write-Host "[mp.playdir] The given path parameter '$Path' does not exist as a valid directory!"
	exit 1
}

$Realpath = Convert-Path -Path $Path -ErrorAction 'Stop'
$Dirfiles = Get-ChildItem -Path $Realpath -File
$Playlist = [Collections.Generic.List[String]]::new()
$Execfile = (Get-Command -Name 'mpv').Path

if ($null -eq $Dirfiles) {
	Write-Host "[mp.playdir] The specified directory '$Realpath' does not contain any files!"
	exit
}

$FileExtsVid = @(
	'.webm', '.mkv', '.mp4', '.mov', '.wmv', '.asf', '.ogv', '.avi', '.ts', '.flv', '.m4v', '.rm', '.rmvb', '.vob',
	'.mpg', '.mp2', '.mpeg', '.mpe', '.mpv', '.m2v', '.mxf', '.m4p', '.drc', '.mts', '.m2ts', '.f4v', '.qt',
	'.3gp', '.3g2', '.mk3d', '.m2p', '.ps', '.tsv', '.evo', '.ogx', '.divx', '.amv', '.yuv'
)

foreach ($File in $Dirfiles) {
	if ($File.Extension -in $FileExtsVid) {
		$Playlist.Add($File.FullName)
	}
}

if ($Playlist.Count -eq 0) {
	Write-Host "[mp.playdir] The specified directory '$Realpath' does not contain any supported media files!"
	exit
}

if ($Random) {
	$Playlist = $Playlist | Get-Random -Shuffle
}

for ($i = 0; $i -lt (($Options | Measure-Object).Count); $i++) {
	$Options[$i] = $Options[$i].Insert(0, '--')
}

# Two (internal) different application call modes:
enum OutputType {Sstr; Pipe}
# Change OutputMode manually here:
$OutputMode = [OutputType]::Sstr

function _Output_Pipe {
	$Playlist | & $Execfile $(if ($Fullscreen) {'--fs'}) $Options '--playlist=-'
}

function _Output_Sstr {
	& $Execfile $(if ($Fullscreen) {'--fs'}) $Options $Playlist
}

switch ($OutputMode) {
	([OutputType]::Sstr) {_Output_Sstr; break}
	([OutputType]::Pipe) {_Output_Pipe; break}
}

