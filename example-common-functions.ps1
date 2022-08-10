function Test-Directory ($Testvalue) {
	if (($null -eq $Testvalue) -or (($Testvalue | Measure-Object).Count -eq 0)) {
		return $false
	}
	elseif (-not (Test-Path -LiteralPath $Testvalue -IsValid)) {
		return $false
	}
	elseif (-not (Test-Path -LiteralPath $Testvalue -PathType Container)) {
		return $false
	}
	else {
		return ((Get-Item -LiteralPath $Testvalue -Force) -is [System.IO.DirectoryInfo])
	}
}




function Test-DirectorySimple ($Test) {
	if (-not (Test-Path -LiteralPath $Test -PathType Container)) {
		return $false
	}
	else {
		return ((Get-Item -LiteralPath $Test -Force) -is [System.IO.DirectoryInfo])
	}
}




function Test-DirectoryPattern ($Testvalue) {
	function Test-DirectoryPatternEntry ($Pattern) {
		if ([WildcardPattern]::ContainsWildcardCharacters($Pattern)) {
			$ResolvedSet = Resolve-Path -Path $Pattern
			if ($null -eq $ResolvedSet) {
				return $false
			}
			else {
				foreach ($Entry in $ResolvedSet) {
					if (-not (Test-Directory $Entry)) {
						return $false
					}
				}
				return $true
			}
		}
		else {
			return (Test-Directory $Pattern)
		}
	}
	$ValueCount = ($Testvalue | Measure-Object).Count
	if ($ValueCount -eq 0) {
		return $false
	}
	if ($ValueCount -eq 1) {
		return (Test-DirectoryPatternEntry $Testvalue)
	}
	if ($ValueCount -gt 1) {
		foreach ($Entry in $Testvalue) {
			if (-not (Test-DirectoryPatternEntry $Entry)) {
				return $false
			}
		}
		return $true
	}
}




function Test-PathSet ([System.String[]] $PathSet) {
	$Caller = (Get-Variable MyInvocation -Scope 1).Value.MyCommand.Name
	if ($Caller -eq '') {
		$Caller = 'Test-PathSet'
		$RetBln = $false
	}
	else {
		$RetBln = $true
	}
	$SetCnt = ($PathSet | Measure-Object).Count
	if ($SetCnt -eq 0) {
		Write-Host "[$Caller] Error: No path set has been specified!" -ForegroundColor DarkRed
		if ($RetBln) {return $false} else {return}
	}
	elseif ($SetCnt -eq 1) {
		return (Test-Directory $PathSet)
	}
	else {
		foreach ($PathEntry in $PathSet) {
			if (-not (Test-Directory $PathEntry)) {
				return $false
			}
		}
		return $true
	}
}




function Get-PathSet ([System.String[]] $PathSet) {
	$Caller = (Get-Variable MyInvocation -Scope 1).Value.MyCommand.Name
	if ($Caller -eq '') {
		$Caller = 'Get-PathSet'
		$RetBln = $false
	}
	else {
		$RetBln = $true
	}
	$SetCnt = ($PathSet | Measure-Object).Count
	if ($SetCnt -eq 0) {
		Write-Host "[$Caller] Error: No path set has been specified!" -ForegroundColor DarkRed
		if ($RetBln) {return $false} else {return}
	}
	elseif ($SetCnt -eq 1) {
		if (Test-Directory $PathSet) {
			return $PathSet
		}
		else {
			Write-Host "[$Caller] Error: Invalid path argument specified!" -ForegroundColor DarkRed
			if ($RetBln) {return $false} else {return}
		}
	}
	else {
		$TestedPathSet = [System.Collections.Generic.List[System.String]]::new($SetCnt)
		foreach ($PathEntry in $PathSet) {
			if (-not [System.IO.Path]::EndsInDirectorySeparator($PathEntry)) {
				$PathEntry = [System.String]::Concat($PathEntry, [System.IO.Path]::DirectorySeparatorChar)
			}
			if ((Test-Directory $PathEntry) -and (-not ($TestedPathSet.Contains($PathEntry)))) {
				$TestedPathSet.Add($PathEntry)
			}
		}
		if ($TestedPathSet.Count -eq 0) {
			Write-Host "[$Caller] Error: No valid path is contained in the path set!" -ForegroundColor DarkRed
			if ($RetBln) {return $false} else {return}
		}
		else {
			return $TestedPathSet
		}
	}
}




function Switch-SessionState {
	param([Parameter(Mandatory)][ValidateSet('Save', 'Change', 'Restore')][string] $Action)
	function Save-PSDriveState {
		$PSDrivesSaved = [Collections.Generic.List[Object]]::new(26)
		$CurrentFSList = Get-PSDrive -PSProvider FileSystem | Where-Object Name -like '?'
		foreach ($Entry in $CurrentFSList) {
			$FSPropertyMap = @{Drive = $Entry.Name; SavedLocation = $Entry.CurrentLocation}
			$PSDrivesSaved.Add($FSPropertyMap)
		}
		Set-Variable -Name 'StoredPSDriveSet' -Value $PSDrivesSaved -Scope 'Script'
	}
	function Restore-PSDriveState {
		$LocationStore = Get-Variable -Name 'StoredPSDriveSet' -Scope 'Script' -ValueOnly
		foreach ($Entry in $LocationStore) {
			$PSDriveObject = Get-PSDrive -LiteralName $Entry.Drive
			$PSDriveObject.CurrentLocation = $Entry.SavedLocation
		}
		Remove-Variable -Name 'StoredPSDriveSet' -Force -Scope 'Script'
	}
	function Save-SessionState {
		Set-Variable -Name 'ErrActPrefSaved' -Value $ErrorActionPreference -Scope 'Script'
		Set-Variable -Name 'ConfrmPrefSaved' -Value $ConfirmPreference -Scope 'Script'
		Set-Variable -Name 'PresentLocation' -Value (Get-Location) -Scope 'Script'
		Save-PSDriveState
	}
	function Change-SessionState {
		Save-SessionState
		Set-Variable -Name 'ErrorActionPreference' -Value ([Management.Automation.ActionPreference]::Stop) -Scope 'Script'
		Set-Variable -Name 'ConfirmPreference' -Value ([Management.Automation.ConfirmImpact]::None) -Scope 'Script'
	}
	function Restore-SessionState {
		Set-Variable -Name 'ErrorActionPreference' -Value $ErrActPrefSaved -Scope 'Script'
		Set-Variable -Name 'ConfirmPreference' -Value $ConfrmPrefSaved -Scope 'Script'
		Set-Location $PresentLocation
		Remove-Variable -Name 'ErrActPrefSaved', 'ConfrmPrefSaved', 'PresentLocation' -Force -Scope 'Script'
		Restore-PSDriveState
	}
	switch ($Action) {
		'Save'    {Save-SessionState; break}
		'Change'  {Change-SessionState; break}
		'Restore' {Restore-SessionState; break}
	}
}




function Create-GciListing {
	param([Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $Path, [switch] $Force, [switch] $ReadOnlyCollection)
	if (Test-Path -LiteralPath $Path -PathType Container) {
		$ItmList, $DirItms = [System.Collections.Generic.List[System.Object]]::new(), $null
		Push-Location -LiteralPath $Path -StackName 'list'
		if ($PWD.Provider.Name -ceq 'FileSystem') {
			if ($Force) {
				$DirItms = Get-ChildItem -Force
			} else {
				$DirItms = Get-ChildItem
			}
		}
		Pop-Location -StackName 'list'
	} else {
		Write-Host -Object "Error: The given path ""$Path"" could not be found!" -ForegroundColor DarkRed
		return
	}
	if ($DirItms -is [System.Object[]]) {
		$ItmList.AddRange($DirItms)
	} elseif ($DirItms -is [System.IO.FileSystemInfo]) {
		$ItmList.Add($DirItms)
	}
	if ($ReadOnlyCollection) {
		$ItmList = $ItmList.AsReadOnly()
	}
	Write-Output $ItmList -NoEnumerate
}




function Create-DirListing {
	param([Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $Path, [switch] $Force, [switch] $Recurse, [switch] $ReadOnlyCollection)
	if (Test-Path -LiteralPath $Path -PathType Container) {
		$ItmList = [System.Collections.Generic.List[System.IO.FileSystemInfo]]::new()
		$EO = [System.IO.EnumerationOptions]::new()
		$DO = Get-Item -LiteralPath $Path
		if ($DO -is [System.IO.DirectoryInfo]) {
			if ($Force) {
				$EO.AttributesToSkip = [System.IO.FileAttributes]::Device
			}
			if ($Recurse) {
				$EO.RecurseSubdirectories = $true
			}
			$DirItms = $DO.GetFileSystemInfos('*', $EO)
		}
	} else {
		Write-Host -Object "Error: The given path ""$Path"" could not be found!" -ForegroundColor DarkRed
		return
	}
	$ItmList.AddRange($DirItms)
	if ($ReadOnlyCollection) {
		$ItmList = $ItmList.AsReadOnly()
	}
	Write-Output $ItmList -NoEnumerate
}
