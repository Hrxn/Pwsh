<#
.SYNOPSIS
Displays information about all available logical drives.

.DESCRIPTION
Returns drive information about all logical drives known to the operating system.
Includes fundamental properties like drive type, drive format type, and capacity.

.PARAMETER Drive
Name of a specific drive that the output will be limited to.

.PARAMETER Infolevel
Set information variant level for the output. Supported values: 0 - 3

.EXAMPLE
fs.drives

.EXAMPLE
fs.drives -Drive E

.INPUTS
String (Drive Name)
A string representing the name of a specific drive.

.OUTPUTS
Object (Drive Info Object [FSDriveInfo])
Writes a custom object representing the properties for each available drive to the pipeline.
If the script is the last command in the pipeline, the objects are displayed in the console.

.LINK
https://github.com/Hrxn/pwsh
#>

#Requires -Version 6.1

[OutputType('FSDriveInfo')]

param (
	[Parameter(Position = 0)]
	[ValidateNotNullorEmpty()]
	[String] $Drive
,
	[Parameter(Position = 1)]
	[ValidateRange(0, 3)]
	[Byte] $Infolevel = 0
)

begin {

	$Outp = [Collections.Generic.List[Object]]::new()

	if ($Drive) {
		try {
			$Drives = [System.IO.DriveInfo]::new($Drive)
		}
		catch {
			Write-Host "[fs.drives] : Error -> Drive parameter '$Drive' is not a valid drive identifier!" -ForegroundColor 'Red'
			exit 1
		}
	}
	else {
		$Drives = [System.IO.DriveInfo]::GetDrives()
	}

}

process {

	foreach ($Entry in $Drives) {
		try {
			$DrvPrp_AvailFreeSpace = $Entry.AvailableFreeSpace
			$DrvPrp_DriveFormat    = $Entry.DriveFormat
			$DrvPrp_DriveType      = $Entry.DriveType
			$DrvPrp_DriveReady     = $Entry.IsReady
			$DrvPrp_DriveName      = $Entry.Name
			$DrvPrp_RootDirectory  = $Entry.RootDirectory
			$DrvPrp_TotalFreeSpace = $Entry.TotalFreeSpace
			$DrvPrp_Totalsize      = $Entry.TotalSize
			$DrvPrp_VolumeLabel    = $Entry.VolumeLabel
		}
		catch [System.UnauthorizedAccessException] {
			$ErrorMsg = "[fs.drives] : Error -> Unauthorized access exception. The system has denied access to '$Entry'!"
			Write-Host $ErrorMsg -ForegroundColor 'DarkRed'
			exit 2
		}
		catch [System.IO.DriveNotFoundException] {
			$ErrorMsg = "[fs.drives] : Error -> The drive '$Entry' is currently not available!"
			Write-Host $ErrorMsg -ForegroundColor 'DarkRed'
			exit 3
		}
		catch [System.IO.IOException] {
			$ErrorMsg = "[fs.drives] : Error -> IOException occurred while querying the drive '$Entry'!"
			Write-Host $ErrorMsg -ForegroundColor 'Red'
			exit 4
		}
		if ($DrvPrp_DriveReady) {
			if ($Infolevel -eq 0) {
				$DriveInfoMap = [pscustomobject]@{
					'DriveName'        = $DrvPrp_DriveName
					'DriveType'        = $DrvPrp_DriveType
					'DriveFormat'      = $DrvPrp_DriveFormat
					'DriveVolumeLabel' = $DrvPrp_VolumeLabel
					'DriveIsReady'     = $DrvPrp_DriveReady
					'RootDirectory'    = $DrvPrp_RootDirectory
					'TotalSize'        = $DrvPrp_Totalsize
					'TotalFreeSpace'   = $DrvPrp_TotalFreeSpace
				}
			}
			elseif ($Infolevel -eq 1) {
				$DriveInfoMap = [pscustomobject]@{
					'DriveVolumeLabel' = $DrvPrp_VolumeLabel
					'DriveIdentifier'  = $DrvPrp_DriveName.Substring(0, 1)
					'DriveFormat'      = $DrvPrp_DriveFormat
					'DriveName'        = $DrvPrp_DriveName.Substring(0, 2)
					'DriveType'        = $DrvPrp_DriveType
					'RootDirectory'    = $DrvPrp_RootDirectory
					'DriveIsReady'     = $DrvPrp_DriveReady
					'TotalSize'        = $DrvPrp_Totalsize
					'TotalFreeSpace'   = $DrvPrp_TotalFreeSpace
					'AvailFreeSpace'   = $DrvPrp_AvailFreeSpace
				}
			}
			elseif ($Infolevel -eq 2) {
				$DriveInfoMap = [pscustomobject]@{
					'DriveVolumeLabel'   = $DrvPrp_VolumeLabel
					'DriveIdentifier'    = $DrvPrp_DriveName.Substring(0, 1)
					'DriveFormat'        = $DrvPrp_DriveFormat
					'DriveName'          = $DrvPrp_DriveName.Substring(0, 2)
					'DriveType'          = $DrvPrp_DriveType
					'RootDirectory'      = $DrvPrp_RootDirectory
					'DriveIsReady'       = $DrvPrp_DriveReady
					'TotalSizeInMB'      = ($DrvPrp_Totalsize / 1MB)
					'TotalFreeSpaceInMB' = ($DrvPrp_TotalFreeSpace / 1MB)
					'AvailFreeSpaceInMB' = ($DrvPrp_AvailFreeSpace / 1MB)
					'TotalUsedSpaceInMB' = (($DrvPrp_Totalsize - $DrvPrp_TotalFreeSpace) / 1MB)
					'TotalUsedPercent'   = [Math]::Round(((($DrvPrp_Totalsize - $DrvPrp_TotalFreeSpace) / $DrvPrp_Totalsize) * 100), 2)
				}
			}
			elseif ($Infolevel -eq 3) {
				$DriveInfoMap = [pscustomobject]@{
					'DriveVolumeLabel'   = $DrvPrp_VolumeLabel
					'DriveIdentifier'    = $DrvPrp_DriveName.Substring(0, 1)
					'DriveFormat'        = $DrvPrp_DriveFormat
					'DriveName'          = $DrvPrp_DriveName.Substring(0, 2)
					'DriveType'          = $DrvPrp_DriveType
					'RootDirectory'      = $DrvPrp_RootDirectory
					'DriveIsReady'       = $DrvPrp_DriveReady
					'TotalSizeInGB'      = ($DrvPrp_Totalsize / 1GB)
					'TotalFreeSpaceInGB' = ($DrvPrp_TotalFreeSpace / 1GB)
					'AvailFreeSpaceInGB' = ($DrvPrp_AvailFreeSpace / 1GB)
					'TotalUsedSpaceInGB' = (($DrvPrp_Totalsize - $DrvPrp_TotalFreeSpace) / 1GB)
					'TotalUsedPercent'   = [Math]::Round(((($DrvPrp_Totalsize - $DrvPrp_TotalFreeSpace) / $DrvPrp_Totalsize) * 100), 2)
				}
			}
		}
		else {
			$DriveInfoMap = [pscustomobject]@{
				'DriveVolumeLabel'   = $DrvPrp_VolumeLabel
				'DriveIdentifier'    = $DrvPrp_DriveName.Substring(0, 1)
				'DriveFormat'        = $DrvPrp_DriveFormat
				'DriveName'          = $DrvPrp_DriveName.Substring(0, 2)
				'DriveType'          = $DrvPrp_DriveType
				'DriveIsReady'       = $DrvPrp_DriveReady
			}
		}
		$Outp.Add($DriveInfoMap)
	}

}

end {
	Write-Output $Outp
}

