# -------------------------------------------------- Declarations to set up this Script -------------------------------------------------- #
$StatusVal = [Byte] 0
$PathParam = [String]::Empty
$PrimColor = [ConsoleColor]::White
$ScndColor = [ConsoleColor]::DarkGray

# This script assumes that you use a default temp directory for various tasks that should be cleaned up automatically.
# If available, the path to this default temp directory is defined by an environment variable.
# Specify the name of this environment variable, or, alternatively, specify a fully-qualified path to your temp directory on the next line:
$WDPathEnv = $Env:FESP_Tempdir

# Running this script without a properly configured environment like described does still work, it won't go up in flames.
# It will simply display an error message instead of the status message that would appear in this place.

# --------------------------------------------------------- Function Definitions --------------------------------------------------------- #
function Print-Unava {
	$InfMsg = "   !    : Could not delete some items in '$(Get-Location)', access not available. May be in use. Or try an elevated shell."
	Write-Host -Object $InfMsg -ForegroundColor 'DarkRed'
}

function Print-Racec {
	$InfMsg = "   !    : Miscounted items in '$(Get-Location)', usually caused by writes to the directory currently handled by the script."
	Write-Host -Object $InfMsg -ForegroundColor 'DarkRed'
}

function Print-Nopth {
	$InfMsg = "   !    : Environment variable is present, but it's not a valid path?!"
	Write-Host -Object $InfMsg -ForegroundColor 'DarkRed'
}

function Print-Noenv {
	$InfMsg = "   !    : Warning, the given environment variable is not available! Check your environment!"
	Write-Host -Object $InfMsg -ForegroundColor 'DarkYellow'
}

function Print-Notmp {
	$InfMsg = "   !    : Environment variable points to a correct path, but the '\Temp' subdirectory does not exist!"
	Write-Host -Object $InfMsg -ForegroundColor 'DarkYellow'
}

function Save-PSDriveState {
	$PSDrivesSaved = [Collections.Generic.List[Object]]::new(26)
	$CurrentFSList = Get-PSDrive -PSProvider FileSystem | Where-Object Name -like '?'
	foreach ($Entry in $CurrentFSList) {
		$FSPropertyMap = @{Drive = $Entry.Name; SavedLocation = $Entry.CurrentLocation}
		$PSDrivesSaved.Add($FSPropertyMap)
	}
	New-Variable -Name 'StoredPSDriveSet' -Value $PSDrivesSaved -Scope 'Script'
}

function Restore-PSDriveState {
	$LocationStore = Get-Variable -Name 'StoredPSDriveSet' -Scope 'Script' -ValueOnly
	foreach ($Entry in $LocationStore) {
		$PSDriveObject = Get-PSDrive -LiteralName $Entry.Drive
		$PSDriveObject.CurrentLocation = $Entry.SavedLocation
	}
	Remove-Variable -Name 'StoredPSDriveSet' -Scope 'Script'
}

function Fancy-Print {
	param([UInt32] $Output)
	switch ($Output) {
		{$Output -gt 1} {$OutMsg = "$Output items have been removed ..."; $OutClr = [ConsoleColor]::DarkCyan; break}
		{$Output -eq 1} {$OutMsg = "$Output item has been removed ..."; $OutClr = [ConsoleColor]::DarkMagenta; break}
		{$Output -eq 0} {$OutMsg = 'Nothing has been deleted. Maybe it was already clean?'; $OutClr = [ConsoleColor]::DarkGray}
	}
	$OutputStr = [String]::Concat('   >    : ', $OutMsg)
	Write-Host -Object $OutputStr -ForegroundColor $OutClr
}

function Total-Print {
	param([UInt32] $Output)
	if ($StatusVal -eq 0) {
		switch ($Output) {
			{$Output -gt 1} {$OutMsg = "$Output items have been removed in total!"; break}
			{$Output -eq 1} {$OutMsg = "$Output item has been removed in total!"; break}
			{$Output -eq 0} {$OutMsg = 'Nothing to be found. All the things have already been cleaned, apparently!'}
		}
		$OutClr = ($Output -gt 0) ? [ConsoleColor]::Cyan : [ConsoleColor]::DarkGray
		$Prefix = '   =    : '
	}
	if ($StatusVal -gt 0) {
		switch ($Output) {
			{$Output -gt 1} {$OutMsg = "$Output items have been removed so far!"; break}
			{$Output -eq 1} {$OutMsg = "$Output item has been removed so far!"; break}
			{$Output -eq 0} {$OutMsg = 'Nothing has been deleted!'}
		}
		if ($StatusVal -eq 1) {
			$OutClr = [ConsoleColor]::DarkYellow
			$Prefix, $OutMsg = '   !    : ', [String]::Concat($OutMsg, ' But one of the locations could not be cleaned properly!')
		}
		if ($StatusVal -eq 2) {
			$OutClr = [ConsoleColor]::DarkYellow
			$Prefix, $OutMsg = '   !    : ', [String]::Concat($OutMsg, ' Miscount detected. Basically a race condition, re-run the script!')
		}
	}
	$OutputStr = [String]::Concat($Prefix, $OutMsg)
	Write-Host -Object $OutputStr -ForegroundCOlor $OutClr
}

function Count-Items {
	param($Probe)
	switch ($Probe) {
		{$Probe -is [Object[]]}          {$Retv = [UInt32] $Probe.Count; break}
		{$Probe -is [IO.FileSystemInfo]} {$Retv = [UInt32] 1; break}
		{$Probe -eq $null}               {$Retv = [UInt32] 0}
	}
	return $Retv
}

function Analyze-Pth {
	param($Rsrc)
	$Retv = [UInt32] 0
	$Path = Resolve-Path -LiteralPath $Rsrc
	if ($Path -is [Management.Automation.PathInfo]) {
		$Obtained = Get-ChildItem -Path $Path -Force
		if ($Obtained -eq $null) {
			return $Retv
		}
		else {
			return (Count-Items $Obtained)
		}
	}
	return $Retv
}

function Nuke-Location {
	$CountInit = Analyze-Pth (Get-Location)
	try {
		Remove-Item -Path '*' -Recurse -Force
	}
	catch {
		$script:StatusVal = 1
		Print-Unava
	}
	$CountPost = Analyze-Pth (Get-Location)
	try {
		$DoneCount = $CountInit - $CountPost
	}
	catch {
		$script:StatusVal = 2
		$DoneCount = 0
		Print-Racec
	}
	Fancy-Print -Output $DoneCount
	return $DoneCount
}

function Start-Removal {
	param($Target)
	if (Test-Path -LiteralPath $Target -PathType Container) {
		Push-Location -Path $Target -StackName 'Localstack'
		$Retv = Nuke-Location
		Pop-Location -StackName 'Localstack'
		return $Retv
	}
	return [UInt32] 0
}

function Enter-Tempdir {
	param($Envdir)
	if (Test-Path -LiteralPath $Envdir -PathType Container) {
		$Tmpdir = Join-Path -Path $Envdir -ChildPath 'Temp'
		if (Test-Path -LiteralPath $Tmpdir -PathType Container) {
			return (Start-Removal -Target $Tmpdir)
		}
		else {
			Print-Notmp
			return [UInt32] 0
		}
	}
	else {
		Print-Nopth
		return [UInt32] 0
	}
}

function Clean-Environ {
	param($Envpth)
	if ($Envpth -ne $null) {
		return (Enter-Tempdir -Envdir $Envpth)
	}
	else {
		Print-Noenv
		return [UInt32] 0
	}
}

# --------------------------------------------------------- Definitions Finished --------------------------------------------------------- #

# -------------------------------------------------------------- Begin Main -------------------------------------------------------------- #
Write-Host -Object "[MNTNC] : Simple Cleaning Script -> Now Running..." -ForegroundColor $PrimColor
$ErrorActionPreference, $ConfirmPreference = 'Stop', 'None'
Save-PSDriveState

# ------------------------------------------------------ Tasks: 01 / 04 ------------------------------------------------------ #
Write-Host -Object "[01/04] : Cleaning system temp directory in %WinDir%" -ForegroundColor $ScndColor
$Result01 = Clean-Environ -Envpth $Env:windir

# ------------------------------------------------------ Tasks: 02 / 04 ------------------------------------------------------ #
Write-Host -Object "[02/04] : Cleaning user's temp directory in %LocalAppData%" -ForegroundColor $ScndColor
$Result02 = Clean-Environ -Envpth $Env:LOCALAPPDATA

# ------------------------------------------------------ Tasks: 03 / 04 ------------------------------------------------------ #
Write-Host -Object "[03/04] : Cleaning primary temp processing directory (${WDPathEnv}\Temp)" -ForegroundColor $ScndColor
$Result03 = Clean-Environ -Envpth $WDPathEnv

# ------------------------------------------------------ Tasks: 04 / 04 ------------------------------------------------------ #
$StatusMsg = "[04/04] : Cleaning 'tmp-*' and '*.tmp' content in %WinDir%\System32\config\systemprofile\AppData\Local"
Write-Host -Object $StatusMsg -ForegroundColor $ScndColor
$PathParam = Join-Path -Path $Env:windir -ChildPath 'System32\config\systemprofile\AppData\Local\'
if (Test-Path -LiteralPath $PathParam -PathType Container) {
	Push-Location -LiteralPath $PathParam -StackName 'Stack04'
	$Items04a = Get-ChildItem -Path "*.tmp" -Force -File
	$Items04b = Get-ChildItem -Path "tw-*.tmp" -Force
	$CountInit04a, $CountInit04b = (Count-Items $Items04a), (Count-Items $Items04b)
	try {
		$Items04a | Remove-Item -Force
		$Items04b | Remove-Item -Force
	}
	catch {
		$script:StatusVal = 1
		Print-Unava
	}
	$Items04a = Get-ChildItem -Path "*.tmp" -Force -File
	$Items04b = Get-ChildItem -Path "tw-*.tmp" -Force
	$CountPost04a, $CountPost04b = (Count-Items $Items04a), (Count-Items $Items04b)
	$Result04 = ($CountInit04a + $CountInit04b) - ($CountPost04a + $CountPost04b)
	Pop-Location -StackName 'Stack04'
}
else {
	$Result04 = 0
	Write-Error -Message "The Path '$PathParam' does not exist! This is supposed to be a system dir!" -ErrorId 'SystemError'
}
Fancy-Print -Output $Result04

# ------------------------------------------------ Process Results and Finish ------------------------------------------------ #
$StatusMsg = "[MNTNC] : Simple Cleaning Script -> Cleaned all the things!"
Write-Host -Object $StatusMsg -ForegroundColor $PrimColor

$TotalRmvd = (Get-Variable -Name "Result*" -ValueOnly -Scope 'Script' | Measure-Object -Sum).Sum
Total-Print -Output $TotalRmvd
Restore-PSDriveState

$StatusMsg = "[MNTNC] : Simple Cleaning Script $($PSStyle.Underline)$($PSStyle.Foreground.Green)DONE$($PSStyle.Reset)"
Write-Host -Object $StatusMsg -ForegroundColor 'White'

# --------------------------------------------------------------- End Main --------------------------------------------------------------- #
