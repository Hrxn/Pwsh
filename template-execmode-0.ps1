<#
.SYNOPSIS
<Synopsis>

.DESCRIPTION
<Desciption>

.PARAMETER Command
<Parameter Description>

.INPUTS
<Inputs Description>

.OUTPUTS
<Outputs Description>

.EXAMPLE
<Basic Examples>

.LINK
https://github.com/Hrxn/pwsh
#>

#Requires -Version 7.2

using namespace System.IO

[CmdletBinding()]

param(

	[Parameter(Position=0)]
	[string] $Command,

	[switch] $Help

)

enum Execmode {
	Usage
	Infos
	Other
	Start
}

switch ($Command) {
	{$_ -in @('help', 'info', '--help', '--info', '?') -or $Help} {$Run = [Execmode]::Infos}
	{$_ -in @('--manual', '--guide', '--extended', '--other')}    {$Run = [Execmode]::Other}
	{$_ -eq 'start' -and ($PSBoundParameters.Count -eq 1)}        {$Run = [Execmode]::Start}
	default                                                       {$Run = [Execmode]::Usage}
}

if ($PWD.Provider.Name -ceq 'FileSystem') {
	$OldCurrentDirectory = [System.Environment]::CurrentDirectory
	[System.Environment]::CurrentDirectory = $PWD.Path
}
else {
	$ErrorMessage = 'This script is designed only to work with the built-in FileSystem provider from PowerShell! Check your location!'
	Write-Error -Message $ErrorMessage -Category InvalidOperation -ErrorId PSProviderUnsupported -ErrorAction Stop
}


function Send-Exception ([string] $ExceptionID, [string[]] $InfoCol) {
	$NamePrfx = '[Scriptname]'
	$ColrCatn = $PSStyle.Foreground.White
	$ColrBase = $PSStyle.Foreground.BrightBlack
	$ColrEmph = $PSStyle.Foreground.BrightWhite
	switch ($ExceptionID) {
		'exc-info-01' {
			$ExcMsgPrfx = "${NamePrfx} ${ColrCatn}Info${ColrBase} :"
			$ExcMessage = "${ExcMsgPrfx} Somehow ""${ColrEmph}$($InfoCol[0])${ColrBase}"" is not as expected."
			$ExitNumber, $ExcBasecat = 1, 'DarkMagenta'
		}
		'exc-warn-01' {
			$ExcMsgPrfx = "${NamePrfx} ${ColrCatn}Warning${ColrBase} :"
			$ExcMessage = "${ExcMsgPrfx} It's ""${ColrEmph}$($InfoCol[1])${ColrBase}"" unavailable, " +
							"while ""${ColrEmph}$($InfoCol[0])${ColrBase}"" happened."
			$ExitNumber, $ExcBasecat = 2, 'DarkYellow'
		}
		'exc-erro-01' {
			$ExcMsgPrfx = "${NamePrfx} ${ColrCatn}Exception${ColrBase} :"
			$ExcMessage = "${ExcMsgPrfx} An error in ""${ColrEmph}$($InfoCol[0])${ColrBase}"" occurred."
			$ExitNumber, $ExcBasecat = 3, 'DarkRed'
		}
		'exc-crit-01' {
			$ExcMsgPrfx = "${NamePrfx} ${ColrCatn}Error${ColrBase} :"
			$ExcMessage = "${ExcMsgPrfx} An critical error occured!"
			$ExitNumber, $ExcBasecat = 4, 'Red'
		}
	}
	Write-Host -Object $ExcMessage -ForegroundColor $ExcBasecat
	exit $ExitNumber
}

function Show-Message ([string] $MessageID, [string[]] $InfoCol) {
	$NamePrfx = '[Scriptname]'
	$ColrBase = $PSStyle.Foreground.BrightBlack
	$ColrEmph = $PSStyle.Foreground.BrightWhite
	switch ($MessageID) {
		'msg-info-01' {
			$MessageStr = "${NamePrfx} I'm a message text."
		}
		'msg-hint-01' {
			$MessageStr = "${NamePrfx} I'm an information hint."
		}
	}
	Write-Host -Object $MessageStr
}

function Write-Log ([string] $LogID, [string[]] $InfoCol) {
	if ($null -ne $Env:FSPS_Logdir) {
		$Logdir = $Env:FSPS_Logdir
	} else {
		$Logdir = $PWD.Path
	}
	$Logdir = ([Path]::EndsInDirectorySeparator($Logdir)) ? $Logdir : [System.String]::Concat($Logdir, [Path]::DirectorySeparatorChar)
	$Logsrc = (Split-Path $PSCommandPath -Leaf)
	$Log_s1 = ('-' * 100) + "`n"
	$Log_s2 = ('-' * 140) + "`n"
	switch ($LogID) {
		'log-standard' {
			$LogCatName = 'standard'
			$LogHeading = ">> $((Get-Date).ToString()) << | $Logsrc -> logfile: $LogCatName"
			$LogMessage = "Write something into a log file... like ""$($InfoCol[0])"" even if nothing special has happened?"
			$LogContent = [System.String]::Concat($Log_s1, $LogHeading, "`n", $Log_s2, $LogMessage, "`n", $Log_s2)
		}
		'log-issues' {
			$LogCatName = 'issues'
			$LogHeading = ">> $((Get-Date).ToString()) << | $Logsrc -> logfile: $LogCatName"
			$LogMessage = "There has been a problem with the collection ""$($InfoCol)"" !"
			$LogContent = [System.String]::Concat($Log_s1, $LogHeading, "`n", $Log_s2, $LogMessage, "`n", $Log_s2)
		}
	}
	Add-Content -Value $LogContent -LiteralPath "${Logdir}logfile__${Logsrc}__${LogCatName}.txt"
}


function Show-Info {
	Write-Host '<showing some info here>'
}

function Show-Help {
	Write-Host '<showing some help here>'
}

function Show-More {
	Write-Host '<showing some more here>'
}

function Start-Run {
	Write-Output (5 + 5 + 5 + 1)
}

switch ($Run) {
	([Execmode]::Usage) {Show-Info}
	([Execmode]::Infos) {Show-Help}
	([Execmode]::Other) {Show-More}
	([Execmode]::Start) {Start-Run}
}


[System.Environment]::CurrentDirectory = $OldCurrentDirectory

if ($Run -eq [Execmode]::Start) {
	Write-Host "Finish message here."
}

