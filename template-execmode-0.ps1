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
	$ErrorMessage = 'This script is designed specifically for the built-in FileSystem provider included in PowerShell!'
	Write-Error -Message $ErrorMessage -Category InvalidOperation -ErrorId PSProviderUnsupported -ErrorAction Stop
}

function Show-Status ([string] $ID, [string[]] $Text) {
	switch ($ID) {
		{$_.StartsWith('exc')} {$vtC1 = $ccExce}
		{$_.StartsWith('err')} {$vtC1 = $ccErro}
		{$_.StartsWith('wrn')} {$vtC1 = $ccWarn}
		{$_.StartsWith('inf')} {$vtC1 = $ccInfo}
		{$_.StartsWith('log')} {$vtC1 = $ccLogm}
		{$_.StartsWith('sts')} {$vtC1 = $ccHigh}
	}
	switch ($ID) {
		'err-ca-01' { $Msg = "${vtC1}Error ${ccZero}: The specified argument for parameter ${ccSubt}-Path ${ccZero}" +
			"(${ccShft}'${ccHigh}$($Text[1])${ccShft}'${ccZero}) does not exist as a valid literal path!"
		}
		'err-ca-02' { $Msg = "${vtC1}Error ${ccZero}: The specified argument for parameter ${ccSubt}-Path ${ccZero}" +
			"(${ccShft}'${ccHigh}$($Text[1])${ccShft}'${ccZero}) does not refer to an existing directory!"
		}
		'wrn-ca-01' { $Msg = "${vtC1}Error ${ccZero}: The specified argument for parameter ${ccSubt}-Path ${ccZero}" +
			"(${ccShft}'${ccHigh}$($Text[1])${ccShft}'${ccZero}) could not be resolved!"
		}
		'wrn-ca-02' { $Msg = "${vtC1}Error ${ccZero}: The specified argument for parameter ${ccSubt}-$($Text[1])${ccZero} " +
			"(${ccShft}'${ccHigh}$($Text[2])${ccShft}'${ccZero}) could not be found as a file!"
		}
		'inf-ca-01'  { $Msg = "${vtC1}Info ${ccZero}: The file ${ccShft}'${ccHigh}$($Text[1])${ccShft}'${ccZero} has been " +
			"successfully replaced with the file ${ccShft}'${ccHigh}$($Text[2])${ccShft}'${ccZero} while retaining its filename!"
		}
	}
	$Prefix = "${ccCats}[${vtC1}$($Text[0])${ccCats}]${ccZero}"
	$Output = [string]::Concat($Prefix, ' > ', $Msg)
	Write-Host -Object $Output
}

function Send-Exception ([string] $ExceptionID, [string[]] $InfoCol) {
	$NamePrfx = '[Scriptname]'
	switch ($ExceptionID) {
		'exc-info-01' {
			$ExcMsgPrfx = "${NamePrfx} ${ccInfo}Info${ccZero} :"
			$ExcMessage = "${ExcMsgPrfx} Somehow ""${ccEmph}$($InfoCol[0])${ccZero}"" is not as expected."
			$ExitNumber = 1
		}
		'exc-warn-01' {
			$ExcMsgPrfx = "${NamePrfx} ${ccInfo}Warning${ccZeroBase} :"
			$ExcMessage = "${ExcMsgPrfx} It's ""${ccEmph}$($InfoCol[1])${ccZero}"" unavailable, " +
							"while ""${ccEmph}$($InfoCol[0])${ccZero}"" happened."
			$ExitNumber = 2
		}
		'exc-erro-01' {
			$ExcMsgPrfx = "${NamePrfx} ${ccInfo}Exception${ccZero} :"
			$ExcMessage = "${ExcMsgPrfx} An error in ""${ccEmph}$($InfoCol[0])${ccZero}"" occurred."
			$ExitNumber = 3
		}
		'exc-crit-01' {
			$ExcMsgPrfx = "${NamePrfx} ${ccInfo}Error${ccZero} :"
			$ExcMessage = "${ExcMsgPrfx} An critical error occured!"
			$ExitNumber = 4
		}
	}
	Show-Status -ID $ExceptionID -Text $InfoCol
	exit $ExitNumber
}

function Write-Log ([string] $LogID, [string[]] $InfoCol) {
	if ($null -ne $Env:FSPS_Logdir) {
		$Logdir = $Env:FSPS_Logdir
	} else {
		$Logdir = $PWD.Path
	}
	$Logdir = ([Path]::EndsInDirectorySeparator($Logdir)) ? $Logdir : [String]::Concat($Logdir, [Path]::DirectorySeparatorChar)
	$Logsrc = (Split-Path $PSCommandPath -Leaf)
	$Log_s1 = ('-' * 100) + "`n"
	$Log_s2 = ('-' * 140) + "`n"
	switch ($LogID) {
		'log-standard' {
			$LogCatName = 'standard'
			$LogHeading = ">> $((Get-Date).ToString()) << | $Logsrc -> logfile: $LogCatName"
			$LogMessage = "Write something into a log file... like ""$($InfoCol[0])"" even if nothing special has happened?"
			$LogContent = [String]::Concat($Log_s1, $LogHeading, "`n", $Log_s2, $LogMessage, "`n", $Log_s2)
		}
		'log-issues' {
			$LogCatName = 'issues'
			$LogHeading = ">> $((Get-Date).ToString()) << | $Logsrc -> logfile: $LogCatName"
			$LogMessage = "There has been a problem with the collection ""$($InfoCol)"" !"
			$LogContent = [String]::Concat($Log_s1, $LogHeading, "`n", $Log_s2, $LogMessage, "`n", $Log_s2)
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

