<#
.SYNOPSIS
Plays a slideshow of the picture files in a given directory with mpv.

.DESCRIPTION
Simple script utilizing mpv to show a slideshow of the picture files in a specified directory.

Dependencies:
	- mpv (https://mpv.io/)

.PARAMETER Path
Specifies the path to the directory containing the picture files you want to display.
Uses the current working location as default if no path is specified.

.PARAMETER Duration
A floating point number setting the average duration in seconds that a single slide is shown.
Uses a default of 4 seconds.

.PARAMETER Options
A collection of string values describing the command-line options that are forwarded on to mpv.

.PARAMETER Random
Switch to show the picture files in randomized order.
Uses the standard alphanumeric sorting by default, as is.

.EXAMPLE
mp.playslides

.EXAMPLE
mp.playslides -Options 'video-zoom=0.82', 'image-display-duration=12.25'

.EXAMPLE
mp.playslides -Path .\Downloads\Wallpapers -Duration 18 -Random

.INPUTS
None. You cannot pipe objects to mp.playslides.ps1.

.OUTPUTS
None. mp.playslides.ps1 does not generate any output.

.LINK
https://github.com/Hrxn/pwsh
#>

#Requires -Version 7.1

param (
	[Parameter()][string] $Path = $PWD.ToString(),
	[Parameter()][double] $Duration = 4.0,
	[Parameter()][switch] $Random = $false,
	[Parameter(ValueFromRemainingArguments)][string[]] $Options
)

if ($PWD.Provider.Name -cne 'FileSystem') {
	Write-Host '[mp.playslides] : Error -> The current working directory is not a valid path in a filesystem!' -ForegroundColor 'Red'
	exit 255
}
if ($null -eq (Get-Command -Name 'mpv' -ErrorAction 'Ignore')) {
	Write-Host '[mp.playslides] : Error -> Dependency Error: Missing dependency: mpv!' -ForegroundColor 'DarkRed'
	exit 254
}
if ($Path -eq '--help' -or $Path -eq '?') {
	Write-Host '[mp.playslides] Usage: mp.playdir.ps1 [-Path] [<PATH>] [-Duration] [<SECONDS>] [-Options] [<MPV OPTIONS>] [-Random]'
	exit 0
}
if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
	Write-Host "[mp.playslides] The given path parameter '$Path' does not exist as a valid directory!"
	exit 1
}

$Realpath = Convert-Path -LiteralPath $Path -ErrorAction 'Stop'
$Dirfiles = Get-ChildItem -Path $Realpath -File
$Playlist = [Collections.Generic.List[String]]::new()
$Execfile = (Get-Command -Name 'mpv').Path

if ($null -eq $Dirfiles) {
	Write-Host "[mp.playslides] The specified directory '$Realpath' does not contain any files!"
	exit
}

$FileExtsPic = @(
	'.jpg', '.jpeg', '.png', '.webp', '.jpe', '.jxl', '.tiff', '.tif', '.jif', '.jfif', '.avif', '.heif', '.heic', '.jxr', '.jfi', '.j2k',
	'.jp2', '.hdp', '.gif', '.wdp', '.hdr', '.exr', '.ppm', '.pbm', '.bpg', '.svg', '.tga', '.bmp', '.jpf', '.jpm', '.jpg2', '.jpx',
	'.j2c', '.jpc', '.apng', '.mng', '.wp2', '.heifs', '.heics', '.avci', '.avcs', '.avifs', '.pnm'
)

foreach ($File in $Dirfiles) {
	if ($File.Extension -in $FileExtsPic) {
		$Playlist.Add($File.FullName)
	}
}

if ($Playlist.Count -eq 0) {
	Write-Host "[mp.playslides] The specified directory '$Realpath' does not contain any supported picture files!"
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
	$Playlist | & $Execfile '--fs' "--image-display-duration=$Duration" $Options '--playlist=-'
}

function _Output_Sstr {
	& $Execfile '--fs' "--image-display-duration=$Duration" $Options $Playlist
}

switch ($OutputMode) {
	([OutputType]::Sstr) {_Output_Sstr; break}
	([OutputType]::Pipe) {_Output_Pipe; break}
}

