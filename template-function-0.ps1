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

	function Show-Status ([String] $ID, [String[]] $Text) {
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
		$Output = [String]::Concat($Prefix, ' > ', $Msg)
		Write-Host -Object $Output
	}

	function Send-Exception ([String] $ExceptionID, [String[]] $InfoCol) {
		$NamePrfx = '[Scriptname]'
		switch ($ExceptionID) {
			'exc-info-01' {
				$ExcMsgPrfx = "${NamePrfx} ${ccInfo}Info${ccZero} :"
				$ExcMessage = "${ExcMsgPrfx} Somehow ""${ccEmph}$($InfoCol[0])${ccZero}"" is not as expected."
				$ExceptType = [System.NotImplementedException]::new($ExcMessage)
				$ExitNumber = 1
			}
			'exc-warn-01' {
				$ExcMsgPrfx = "${NamePrfx} ${ccInfo}Warning${ccZero} :"
				$ExcMessage = "${ExcMsgPrfx} It's ""${ccEmph}$($InfoCol[1])${ccZero}"" unavailable, " +
								"while ""${ccEmph}$($InfoCol[0])${ccZero}"" happened."
				$ExceptType = [System.NotSupportedException]::new($ExcMessage)
				$ExitNumber = 2
			}
			'exc-erro-01' {
				$ExcMsgPrfx = "${NamePrfx} ${ccInfo}Exception${ccZero} :"
				$ExcMessage = "${ExcMsgPrfx} An error in ""${ccEmph}$($InfoCol[0])${ccZero}"" occurred."
				$ExceptType = [System.NotImplementedException]::new($ExcMessage)
				$ExitNumber = 3
			}
			'exc-crit-01' {
				$ExcMsgPrfx = "${NamePrfx} ${ccInfo}Error${ccZero} :"
				$ExcMessage = "${ExcMsgPrfx} An critical error occured!"
				$ExceptType = [System.NotSupportedException]::new($ExcMessage)
				$ExitNumber = 4
			}
		}
		Show-Status -ID $ExcMessage -Text $InfoCol
		if ($Raise) {
			throw $ExceptType
		}
		if ($Exit) {
			exit $ExitNumber
		}
	}



	function Write-Log ([String] $LogID, [String[]] $InfoCol) {
		if ($null -ne $Env:FSPS_Logdir) {
			$Logdir = $Env:FSPS_Logdir
		} elseif ($PWD.Provider.Name -ceq 'FileSystem') {
			$Logdir = $PWD.Path
		} else {
			$Logdir = [Path]::GetTempPath()
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

