<#
.SYNOPSIS
Displays information about all available logical drives.

.DESCRIPTION
Returns drive information about all logical drives known to the operating system.
Includes fundamental properties like drive type, drive format type, and capacity.

.PARAMETER Drive
Name of a specific drive that the output will be limited to.

.PARAMETER Infolevel
Set information variant level for the output. Supported values: 0-5

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
	[ValidateRange(0, 5)]
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

	function Format-DynamicSizeStr {
		param([UInt64]$bytes)
		if     ($bytes -gt 1pb) {[String]::Format('{0:N2} PiB', $bytes/1pb)}
		elseif ($bytes -gt 1tb) {[String]::Format('{0:N2} TiB', $bytes/1tb)}
		elseif ($bytes -gt 1gb) {[String]::Format('{0:N2} GiB', $bytes/1gb)}
		elseif ($bytes -gt 1mb) {[String]::Format('{0:N2} MiB', $bytes/1mb)}
		elseif ($bytes -gt 1kb) {[String]::Format('{0:N2} KiB', $bytes/1kb)}
		elseif ($bytes -gt 1)   {[String]::Format('{0:N0} Bytes', $bytes)}
		else                    {'Empty'}
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
			$DrvPrp_TotalSize      = $Entry.TotalSize
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
					'DriveVolumeLabel'  = $DrvPrp_VolumeLabel
					'DriveType'         = $DrvPrp_DriveType
					'DriveFormat'       = $DrvPrp_DriveFormat
					'RootDirectory'     = $DrvPrp_RootDirectory
					'DriveName'         = $DrvPrp_DriveName.Substring(0, 2)
					'DriveIdentifier'   = $DrvPrp_DriveName.Substring(0, 1)
					'TotalSizeStr'      = (Format-DynamicSizeStr $DrvPrp_TotalSize)
					'TotalFreeSpaceStr' = (Format-DynamicSizeStr $DrvPrp_TotalFreeSpace)
					'AvailFreeSpaceStr' = (Format-DynamicSizeStr $DrvPrp_AvailFreeSpace)
					'TotalUsedPercent'   = [Math]::Round(((($DrvPrp_TotalSize - $DrvPrp_TotalFreeSpace) / $DrvPrp_TotalSize) * 100), 2)
				}
			}
			elseif ($Infolevel -eq 1) {
				$DriveInfoMap = [pscustomobject]@{
					'DriveVolumeLabel'  = $DrvPrp_VolumeLabel
					'DriveType'         = $DrvPrp_DriveType
					'DriveFormat'       = $DrvPrp_DriveFormat
					'RootDirectory'     = $DrvPrp_RootDirectory
					'DriveName'         = $DrvPrp_DriveName.Substring(0, 2)
					'TotalSizeStr'      = (Format-DynamicSizeStr $DrvPrp_TotalSize)
					'TotalFreeSpaceStr' = (Format-DynamicSizeStr $DrvPrp_TotalFreeSpace)
					'TotalUsedPercent'   = [Math]::Round(((($DrvPrp_TotalSize - $DrvPrp_TotalFreeSpace) / $DrvPrp_TotalSize) * 100), 2)
				}
			}
			elseif ($Infolevel -eq 2) {
				$DriveInfoMap = [pscustomobject]@{
					'DriveVolumeLabel' = $DrvPrp_VolumeLabel
					'DriveIdentifier'  = $DrvPrp_DriveName.Substring(0, 1)
					'DriveFormat'      = $DrvPrp_DriveFormat
					'DriveName'        = $DrvPrp_DriveName.Substring(0, 2)
					'DriveType'        = $DrvPrp_DriveType
					'RootDirectory'    = $DrvPrp_RootDirectory
					'DriveIsReady'     = $DrvPrp_DriveReady
					'TotalSize'        = $DrvPrp_TotalSize
					'TotalFreeSpace'   = $DrvPrp_TotalFreeSpace
					'AvailFreeSpace'   = $DrvPrp_AvailFreeSpace
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
					'TotalSizeInMB'      = ($DrvPrp_TotalSize / 1mb)
					'TotalFreeSpaceInMB' = ($DrvPrp_TotalFreeSpace / 1mb)
					'AvailFreeSpaceInMB' = ($DrvPrp_AvailFreeSpace / 1mb)
					'TotalUsedSpaceInMB' = (($DrvPrp_TotalSize - $DrvPrp_TotalFreeSpace) / 1mb)
					'TotalUsedPercent'   = [Math]::Round(((($DrvPrp_TotalSize - $DrvPrp_TotalFreeSpace) / $DrvPrp_TotalSize) * 100), 2)
				}
			}
			elseif ($Infolevel -eq 4) {
				$DriveInfoMap = [pscustomobject]@{
					'DriveVolumeLabel'   = $DrvPrp_VolumeLabel
					'DriveIdentifier'    = $DrvPrp_DriveName.Substring(0, 1)
					'DriveFormat'        = $DrvPrp_DriveFormat
					'DriveName'          = $DrvPrp_DriveName.Substring(0, 2)
					'DriveType'          = $DrvPrp_DriveType
					'RootDirectory'      = $DrvPrp_RootDirectory
					'DriveIsReady'       = $DrvPrp_DriveReady
					'TotalSizeInGB'      = ($DrvPrp_TotalSize / 1gb)
					'TotalFreeSpaceInGB' = ($DrvPrp_TotalFreeSpace / 1gb)
					'AvailFreeSpaceInGB' = ($DrvPrp_AvailFreeSpace / 1gb)
					'TotalUsedSpaceInGB' = (($DrvPrp_TotalSize - $DrvPrp_TotalFreeSpace) / 1gb)
					'TotalUsedPercent'   = [Math]::Round(((($DrvPrp_TotalSize - $DrvPrp_TotalFreeSpace) / $DrvPrp_TotalSize) * 100), 2)
				}
			}
			elseif ($Infolevel -eq 5) {
				$DriveInfoMap = [pscustomobject]@{
					'DriveName'        = $DrvPrp_DriveName
					'DriveType'        = $DrvPrp_DriveType
					'DriveFormat'      = $DrvPrp_DriveFormat
					'DriveVolumeLabel' = $DrvPrp_VolumeLabel
					'DriveIsReady'     = $DrvPrp_DriveReady
					'RootDirectory'    = $DrvPrp_RootDirectory
					'TotalSize'        = $DrvPrp_TotalSize
					'TotalFreeSpace'   = $DrvPrp_TotalFreeSpace
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

