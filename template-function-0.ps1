<#
.SYNOPSIS
<Synopsis>

.DESCRIPTION
<Desciption>

.PARAMETER InputParam
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

#Requires -Version 7.3

using namespace System.IO

[CmdletBinding()]

param(

	[Parameter(Position=0, Mandatory, ValueFromPipeline)]
	[string[]]
	$InputParam,

	[switch]
	$Raise,

	[switch]
	$Exit

)

begin {

	function Send-Exception ([string] $ExceptionID, [string[]] $InfoCol) {
		$NamePrfx = '[Scriptname]'
		$ColrCatn = $PSStyle.Foreground.White
		$ColrBase = $PSStyle.Foreground.BrightBlack
		$ColrEmph = $PSStyle.Foreground.BrightWhite
		switch ($ExceptionID) {
			'exc-info-01' {
				$ExcMsgPrfx = "${NamePrfx} ${ColrCatn}Info${ColrBase} :"
				$ExcMessage = "${ExcMsgPrfx} Somehow ""${ColrEmph}$($InfoCol[0])${ColrBase}"" is not as expected."
				$ExceptType = [System.NotImplementedException]::new($ExcMessage)
				$ExitNumber, $ExcBasecat = 1, 'DarkMagenta'
			}
			'exc-warn-01' {
				$ExcMsgPrfx = "${NamePrfx} ${ColrCatn}Warning${ColrBase} :"
				$ExcMessage = "${ExcMsgPrfx} It's ""${ColrEmph}$($InfoCol[1])${ColrBase}"" unavailable, " +
								"while ""${ColrEmph}$($InfoCol[0])${ColrBase}"" happened."
				$ExceptType = [System.NotSupportedException]::new($ExcMessage)
				$ExitNumber, $ExcBasecat = 2, 'DarkYellow'
			}
			'exc-erro-01' {
				$ExcMsgPrfx = "${NamePrfx} ${ColrCatn}Exception${ColrBase} :"
				$ExcMessage = "${ExcMsgPrfx} An error in ""${ColrEmph}$($InfoCol[0])${ColrBase}"" occurred."
				$ExceptType = [System.NotImplementedException]::new($ExcMessage)
				$ExitNumber, $ExcBasecat = 3, 'DarkRed'
			}
			'exc-crit-01' {
				$ExcMsgPrfx = "${NamePrfx} ${ColrCatn}Error${ColrBase} :"
				$ExcMessage = "${ExcMsgPrfx} An critical error occured!"
				$ExceptType = [System.NotSupportedException]::new($ExcMessage)
				$ExitNumber, $ExcBasecat = 4, 'Red'
			}
		}
		Write-Host -Object $ExcMessage -ForegroundColor $ExcBasecat
		if ($Raise) {
			throw $ExceptType
		}
		if ($Exit) {
			exit $ExitNumber
		}
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
		} elseif ($PWD.Provider.Name -ceq 'FileSystem') {
			$Logdir = $PWD.Path
		} else {
			$Logdir = [Path]::GetTempPath()
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

}

process {

	foreach ($Entry in $InputParam) {
		#
		#
		#
		#
	}

}

end {
	#
	#
	#
	#
}

clean {
	#
	#
	#
	#
}

