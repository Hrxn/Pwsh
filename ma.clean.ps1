# -------------------------------------------------- Declarations for this entire Scope -------------------------------------------------- #
$StatusVal = [Byte] 0
$PathParam = [String]::Empty
$PrimColor = [System.ConsoleColor]::White
$ScndColor = [System.ConsoleColor]::DarkGray

# --------------------------------------------------------- Function Definitions --------------------------------------------------------- #
function Print-Unava {
	$InfMsg = "   !    : Could not delete some items in '$(Get-Location)', access not available. May be in use. Or try an elevated shell."
	Write-Host -Object $InfMsg -ForegroundColor 'DarkRed'
}

function Print-Nopth {
	$InfMsg = "   !    : Environment variable is present, but it's not a valid Path?!"
	Write-Host -Object $InfMsg -ForegroundColor 'DarkRed'
}

function Print-Noenv {
	$InfMsg = "   !    : Warning, the given environment variable is not available! Check your environment!"
	Write-Host -Object $InfMsg -ForegroundColor 'DarkYellow'
}

function Print-Notmp {
	$InfMsg = "   !    : Environment variable points to a correct Path, but the '\Temp' subdirectory does not exist!"
	Write-Host -Object $InfMsg -ForegroundColor 'DarkYellow'
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
		$OutClr = ($Output -gt 0) ? [System.ConsoleColor]::Cyan : [System.ConsoleColor]::DarkGray
		$Prefix = '   =    : '
	}
	if ($StatusVal -eq 1) {
		switch ($Output) {
			{$Output -gt 1} {$OutMsg = "$Output items have been removed so far!"; break}
			{$Output -eq 1} {$OutMsg = "$Output item has been removed so far!"; break}
			{$Output -eq 0} {$OutMsg = 'Nothing has been deleted!'}
		}
		$OutClr = [System.ConsoleColor]::DarkYellow
		$Prefix, $OutMsg = '   !    : ', [String]::Concat($OutMsg, ' But there has been some issue in one of the locations!')
	}
	$OutputStr = [String]::Concat($Prefix, $OutMsg)
	Write-Host -Object $OutputStr -ForegroundCOlor $OutClr
}

function Count-Items {
	param($Item)
	switch ($Item) {
		{$Item -is [System.Object[]]}         {$Retv = [UInt32] $Item.Count; break}
		{$Item -is [System.IO.DirectoryInfo]} {$Retv = [UInt32] 1; break}
		{$Item -is [System.IO.FileInfo]}      {$Retv = [UInt32] 1; break}
		{$Item -eq $null}                     {$Retv = [Uint32] 0}
	}
	return $Retv
}

function Analyze-Pth {
	param($Rsrc)
	$Retv = [UInt32] 0
	$Path = Resolve-Path -LiteralPath $Rsrc
	if ($Path -is [System.Management.Automation.PathInfo]) {
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
		Remove-Item -Path "*" -Recurse -Force
	}
	catch {
		$script:StatusVal = 1
		Print-Unava
	}
	$CountPost = Analyze-Pth (Get-Location)
	$DoneCount = $CountInit - $CountPost
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
$ErrActPrefSaved, $ConfrmPrefSaved = $ErrorActionPreference, $ConfirmPreference
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$ConfirmPreference = [System.Management.Automation.ConfirmImpact]::None

# ------------------------------------------------------ Tasks: 01 / 04 ------------------------------------------------------ #
Write-Host -Object "[01/04] : Cleaning System Temp directory in %Windir%" -ForegroundColor $ScndColor
$Result01 = Clean-Environ -Envpth $Env:windir

# ------------------------------------------------------ Tasks: 02 / 04 ------------------------------------------------------ #
Write-Host -Object "[02/04] : Cleaning User's Temp directory in %LocalAppData%" -ForegroundColor $ScndColor
$Result02 = Clean-Environ -Envpth $Env:LocalAppData

# ------------------------------------------------------ Tasks: 03 / 04 ------------------------------------------------------ #
Write-Host -Object "[03/04] : Cleaning temporary processing directory (`$Env:FSWorkdir\Temp)" -ForegroundColor $ScndColor
$Result03 = Clean-Environ -Envpth $Env:FSWorkdir

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
	Set-Location
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
$TotalRmvd = (Get-Variable -Name "Result*" -ValueOnly | Measure-Object -Sum).Sum
Total-Print -Output $TotalRmvd
$StatusMsg = "[MNTNC] : Simple Cleaning Script $($PSStyle.Italic)$($PSStyle.Foreground.Green)DONE$($PSStyle.Reset)"
Write-Host -Object $StatusMsg -ForegroundColor $PrimColor

$ErrorActionPreference = $ErrActPrefSaved
$ConfirmPreference = $ConfrmPrefSaved
Remove-Variable -Name "Result*", "Items*", "CountInit*", "CountPost*"
Remove-Variable -Name 'ErrActPrefSaved', 'ConfrmPrefSaved', 'StatusVal', 'StatusMsg', 'TotalRmvd', 'PathParam', 'PrimColor', 'ScndColor'

# --------------------------------------------------------------- End Main --------------------------------------------------------------- #
