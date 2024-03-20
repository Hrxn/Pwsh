<#PSScriptInfo

.VERSION 1.0

.GUID fe1ffe19-f980-4070-9914-b36cbe58322f

.AUTHOR hrxn.public@gmail.com

.COPYRIGHT (c)Hrxn

.TAGS PowerShell Development Scripting PSScriptAnalyzer Analysis

.LICENSEURI https://github.com/Hrxn/Pwsh/blob/master/LICENSE

.PROJECTURI https://github.com/Hrxn/Pwsh

.EXTERNALMODULEDEPENDENCIES PSScriptAnalyzer

.RELEASENOTES
	- 1.0 [2023-08-10] | Initial release
#>

<#
.SYNOPSIS
	PSScriptAnalyzer utility script

.DESCRIPTION
	Use `Invoke-ScriptAnalyzer` with a predefined set of rules and options.

	Dependencies:
	1) PSScriptAnalyzer (https://github.com/PowerShell/PSScriptAnalyzer)

.PARAMETER Path
	Specifies the path to the scripts or module to be analyzed. Wildcard characters are supported.
	Possible are paths to script (.ps1) or module (.psm1) files, or to a directory that contains scripts or modules. Other filetpyes are ignored.
	The default value is the current working directory.

.PARAMETER ScriptDefinition
	Run the analysis on commands, functions, or expressions represented in a string.

.PARAMETER Preset
	Specifies the path to a file containing a user-defined PSScriptAnalyzer profile. A script analyzer profile file describes a predefined set of
	rules and rule options to be used for analysis. Rules in the profile take precedence over the same parameters and values specified at the command-line.
	If no value is provided for the 'Preset' parameter, analysis will fall back to a default preset that is distributed together with this script
	at './Preferences/Fesp.PowerShell.PSScriptAnalyzer.Preset.All.psd1'

.PARAMETER Severity
	Only select rule violations with the specified severity.

.PARAMETER Recurse
	Runs script analyzer on the files in the 'Path' directory and all subdirectories recursively.

.PARAMETER ReportSummary
	Combines all rule violations in a summary.

.PARAMETER SuppressedOnly
	Only select rule violations that have been suppressed by using the suppression attribute (SuppressMessageAttribute) in the source code.

.EXAMPLE
	ps.lint.ps1 -Path ps.lint.ps1

.EXAMPLE
	ps.lint.ps1 .\PowerShell\MyModule

.INPUTS
	'Path' or 'ScriptDefinition' as String

.OUTPUTS
	Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord, Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.SuppressedRecord

.LINK
	https://github.com/Hrxn/pwsh
#>

#Requires -Version 7.2

[CmdletBinding(DefaultParameterSetName = 'Path')]
param(
	[Parameter(ParameterSetName = 'Path', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
	[SupportsWildcards()]
	[string[]] $Path = $PWD.Path,

	[Parameter(ParameterSetName = 'ScriptDefinition', Position = 0, ValueFromPipelineByPropertyName)]
	[string] $ScriptDefinition,

	[Parameter(Position = 1)]
	[string] $Preset,

	[ValidateSet('Warning', 'Error', 'Information', 'ParseError')]
	[string[]] $Severity,

	[switch] $Recurse,

	[switch] $ReportSummary,

	[switch] $SuppressedOnly,

	[switch] $IncludeSuppressed
)

begin {
	function Show-Message ($In) {
		Write-Host -Object $In
	}

	try {
		Import-Module -Name 'PSScriptAnalyzer' -Force -ErrorAction Stop
	} catch {
		Show-Message ("`e[38;5;242m[`e[38;5;196mps.lint`e[38;5;242m]`e[38;5;242m[`e[38;5;196mError`e[38;5;242m] `e[38;5;231m- `e[38;5;196mERROR`e[38;5;231m -`e[0m Unable to imp" +
			"ort module `e[38;5;179m'`e[38;5;41mPSScriptAnalyzer`e[38;5;179m'`e[0m, please make sure that it is correctly installed on your system!")
		exit 1
	}

	if ($SuppressedOnly -and $IncludeSuppressed) {
		Show-Message ("`e[38;5;242m[`e[38;5;196mps.lint`e[38;5;242m]`e[38;5;242m[`e[38;5;196mError`e[38;5;242m] `e[38;5;231m- `e[38;5;196mERROR`e[38;5;231m -`e[0m Both " +
			"`e[38;5;179m'`e[38;5;8m-SuppressedOnly`e[38;5;179m'`e[0m and `e[38;5;179m'`e[38;5;8m-IncludeSuppressed`e[38;5;179m'`e[0m have been specified: " +
			"You can only use one of these flags at a time!")
		exit 2
	}
	if ($Preset) {
		if ([System.IO.File]::Exists([System.IO.Path]::GetFullPath($Preset, $PWD))) {
			$ScriptAnalyzerSettings = [System.IO.Path]::GetFullPath($Preset, $PWD)
		} else {
			Show-Message ("`e[38;5;242m[`e[38;5;196mps.lint`e[38;5;242m]`e[38;5;242m[`e[38;5;196mError`e[38;5;242m] `e[38;5;231m- `e[38;5;196mERROR`e[38;5;231m -`e[0m Provided " +
				"value for the argument `e[38;5;179m'`e[38;5;41mPreset`e[38;5;179m'`e[0m: `e[38;5;179m'{0}`e[38;5;179m'`e[0m is not a preset file that exists!" -f $Preset)
				exit 3
		}
	} else {
		$ScriptAnalyzerSettings = [System.IO.Path]::Join($PSScriptRoot, 'Preferences', 'Fesp.PowerShell.PSScriptAnalyzer.Preset.All.psd1')
	}
}

process {
	$ScriptAnalyzerParams = @{
		Settings      = $ScriptAnalyzerSettings
		ReportSummary = $ReportSummary
	}
	if ($Severity) {
		$ScriptAnalyzerParams += @{ Severity = $Severity }
	}
	if ($PSCmdlet.ParameterSetName -ceq 'Path') {
		foreach ($PathEntry in $Path) {
			if ($IncludeSuppressed) {
				Invoke-ScriptAnalyzer @ScriptAnalyzerParams -Path $PathEntry -IncludeSuppressed -Recurse:$Recurse
			} else {
				Invoke-ScriptAnalyzer @ScriptAnalyzerParams -Path $PathEntry -SuppressedOnly:$SuppressedOnly -Recurse:$Recurse
			}
		}
	} else {
		if (-not [System.String]::IsNullOrWhiteSpace($ScriptDefinition)) {
			if ($IncludeSuppressed) {
				Invoke-ScriptAnalyzer @ScriptAnalyzerParams -ScriptDefinition $ScriptDefinition -IncludeSuppressed
			} else {
				Invoke-ScriptAnalyzer @ScriptAnalyzerParams -ScriptDefinition $ScriptDefinition -SuppressedOnly:$SuppressedOnly
			}
		} else {
			Show-Message ("`e[38;5;242m[`e[38;5;196mps.lint`e[38;5;242m]`e[38;5;242m[`e[38;5;196mError`e[38;5;242m] `e[38;5;231m- `e[38;5;196mERROR`e[38;5;231m -`e[0m Provided " +
				"value for the argument `e[38;5;179m'`e[38;5;41mScriptDefinition`e[38;5;179m'`e[0m: `e[38;5;179m'{0}`e[38;5;179m'`e[0m is not valid!" -f $ScriptDefinition)
		}
	}
}
