<#
.SYNOPSIS
Displays information of parameters.

.DESCRIPTION
Returns the available parameters and their properties for a specified command or cmdlet.
Result can be limited to a given name of a specific parameter.

.PARAMETER Command
Specifies the name of a command or cmdlet that will have its parameters shown.

.PARAMETER Parameter
Name of a specific parameter that the output will be limited to.

.EXAMPLE
ps.paraminfo Convert-Path

.EXAMPLE
ps.paraminfo -Command 'Get-ChildItem' -Parameter Force

.INPUTS
String (Command Name), (Parameter Name)
Input a string representing the name of a command/cmdlet.
Input a string representing the name of a specific parameter.

.OUTPUTS
Object (Parameter Info Object [PSParameterInfo])
Writes a custom object representing the properties of a parameter to the pipeline.
If the script is the last command in the pipeline, the objects are displayed in the console.
#>

[CmdletBinding()]
[OutputType('PSParameterInfo')]

param (
	[Parameter(
				Position = 0,
				Mandatory,
				ValueFromPipeline,
				ValueFromPipelineByPropertyName,
				HelpMessage = 'Enter the name of a cmdlet'
	)]
	[ValidateNotNullorEmpty()]
	[String] $Command,

	[Parameter(
				Position = 1,
				HelpMessage = 'Enter the name of a parameter'
	)]
	[String] $Parameter
)

begin {

	function Test-ParamAttribute ($TestObject, $SetName) {
		if ($TestObject -is [System.Management.Automation.ParameterAttribute] -and $TestObject.ParameterSetName -eq $SetName) {
			return $true
		}
		else {
			return $false
		}
	}

	$CommonParameters = @(
		'Verbose',
		'Debug',
		'ErrorAction',
		'ErrorVariable',
		'WarningAction',
		'WarningVariable',
		'OutVariable',
		'OutBuffer',
		'WhatIf',
		'Confirm',
		'InformationAction',
		'InformationVariable',
		'PipelineVariable'
	)
}

process {

	try {
		$GivenCommand = Get-Command -Name $Command -ErrorAction 'Stop'
		if ($GivenCommand.CommandType -eq 'Alias') {
			$ParamInfo = (Get-Command -Name $GivenCommand.ResolvedCommand -ErrorAction 'Stop').Parameters
		}
		else {
			$ParamInfo = $GivenCommand.Parameters
		}
	}
	catch {
		Write-Host "[ps.paraminfo] Error: '$Command' could not be found as a command!" -ForegroundColor 'DarkRed'
		exit 1
	}

	if ($ParamInfo.psbase.Count -gt 0) {
		if ($Parameter) {
			if ($ParamInfo.ContainsKey($Parameter)) {
				$ParamOutp = $Parameter
			}
			else {
				Write-Host "[ps.paraminfo] Error: A parameter called '$Parameter' could not be found!" -ForegroundColor 'DarkRed'
				exit 2
			}
		}
		else {
			$ParamOutp = $ParamInfo.Keys | Where-Object {$CommonParameters -notcontains $_}
		}
		$ParamCount = ($ParamOutp | Measure-Object).Count
		if ($ParamCount -gt 0) {
			$ParamOutp | ForEach-Object {
				$Name = $_
				$Type = $ParamInfo.Item($Name).ParameterType
				$Aliases = $ParamInfo.Item($Name).Aliases -join ', '
				$ParamSets = $ParamInfo.Item($Name).ParameterSets.Keys
				$IsDynamic = $ParamInfo.Item($Name).IsDynamic
				foreach ($Set in $ParamSets) {
					$Attributes = $ParamInfo.Item($Name).Attributes | Where-Object {Test-ParamAttribute -TestObject $_ -SetName $Set}
					if ($Attributes.Position -ge 0) {
						$PositionValue = $Attributes.position
					}
					else {
						$PositionValue = 'None (Named Parameter)'
					}
					$Outp = [PSObject]@{
									Name                            = $Name
									Type                            = $Type
									Aliases                         = $Aliases
									Position                        = $PositionValue
									Mandatory                       = $Attributes.Mandatory
									IsDynamic                       = $IsDynamic
									ParameterSet                    = $Attributes.ParameterSetName -replace '__', ''
									ValueFromPipeline               = $Attributes.ValueFromPipeline
									ValueFromPipelineByPropertyName = $Attributes.ValueFromPipelineByPropertyName

								}
					Write-Output $Outp
				}
			}
		}
	}
	else {
		Write-Host "[ps.paraminfo] Warning: No defined parameters found for the command '$Command'." -ForegroundColor 'DarkYellow'
		exit 3
	}

}

end {
	# Nothing to do here.
}

