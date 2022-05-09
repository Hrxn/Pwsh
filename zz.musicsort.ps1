#Requires -Version 7.2

param
(
	[string] $Command,
	[switch] $Help
)

$RunMode = 'norun'
$InfoCmd = 'help', 'info', '--help', '?'

if ($Help -or ($Command -in $InfoCmd)) {
	$RunMode = 'infos'
}

if (($Command -eq 'start') -and ($RunMode -eq 'norun') -and (-not ($args.Count -gt 0))) {
	$RunMode = 'start'
}

# --------------------------------------- Begin Constants, Variables, Enums, and Type Declarations --------------------------------------- #

New-Variable -Name 'FileExtsAudi' -Option Constant -Value @(
	'.flac', '.mp3', '.aac', '.opus', '.m4a', '.ogg', '.oga', '.mogg', '.wma', '.ape', '.wav', '.alac', '.mpc', '.aiff', '.mka', '.mpga',
	'.pcm', '.m4b', '.m4p', '.dsf', '.wv', '.raw', '.ac3', '.tta', '.au', '.shn', '.aif', '.cda', '.m2a', '.mp1', '.mp2', '.mpa', '.la',
	'.mpx', '.rf64', '.wvc', '.snd', '.bwf', '.mp+', '.mpp', '.w64', '.ra', '.ram', '.ofr', '.ofs', '.spx', '.tak', '.wave', '.mid'
)

New-Variable -Name 'FileExtsImgs' -Option Constant -Value @(
	'.jpg', '.jpeg', '.png', '.webp', '.jpe', '.jxl', '.tiff', '.tif', '.jif', '.jfif', '.avif', '.heif', '.heic', '.jxr', '.jfi', '.j2k',
	'.jp2', '.hdp', '.gif', '.wdp', '.hdr', '.exr', '.ppm', '.pbm', '.bpg', '.svg', '.tga', '.bmp', '.jpf', '.jpm', '.jpg2', '.jpx',
	'.j2c', '.jpc', '.apng', '.mng', '.wp2', '.heifs', '.heics', '.avci', '.avcs', '.avifs', '.pnm'
)

New-Variable -Name 'FileExtsMeta' -Option Constant -Value @(
	'.nfo', '.log', '.sfv', '.m3u', '.m3u8', '.cue', '.txt', '.pls', '.xspf', '.smil', '.sig', '.pgp', '.gpg', '.asc', '.md5', '.sha256',
	'.sha', '.sha1', '.sha384', '.sha512', '.asx', '.wpl', '.vlc', '.mpcpl', '.fpl', '.crc', '.rtf', '.html', '.htm', '.xml'
)

New-Variable -Name 'FileExtsArcs' -Option Constant -Value @(
	'.zip', '.rar', '.7z', '.xz', '.lz', '.bzip2', '.bzip', '.gzip', '.gz', '.tar', '.arj', '.arc', '.cab', '.iso', '.lzh', '.lzma',
	'.bz2', '.lz4', '.lzo', '.z', '.zst', '.zstd', '.rz', '.sz', '.cdx', '.pea', '.tgz', '.tbz2', '.zipx', '.dar'
)

New-Variable -Name 'BaseDirCtgrs' -Option Constant -Value @(
	'+Compilations', '+Images', '+Issues', '+Meta', '+Soundtracks', '+Tracks', '+Uns', '+Unt'
)

New-Variable -Name 'BaseCtgrAssc' -Option Constant -Value @{
	'+Images' = 'FileExtsImgs'
	'+Meta'   = 'FileExtsMeta'
	'+Tracks' = 'FileExtsAudi'
	'+Unt'    = 'FileExtsArcs'
}

New-Variable -Name 'SubsDirCtgrs' -Option Constant -Value @(
	'Imgs', 'Meta'
)

New-Variable -Name 'SubsCtgrAssc' -Option Constant -Value @{
	'Imgs' = 'FileExtsImgs'
	'Meta' = 'FileExtsMeta'
}

New-Variable -Name 'InvalidChars' -Option Constant -Value @(
	' ', '!', '-', '_', '#', '^', '´', '`', '~', '°', '=', '§', '$', '%', '&', "'"
)

New-Variable -Name 'SetDirPattrn' -Option Constant -Value @(
	'* - *', '*_-_*', '*.-.*', '*-*'
)

# ----------------------------------------------- End Declarations and Assignments Section ----------------------------------------------- #

# ------------------------------------------------------ Begin Text Outputs Section ------------------------------------------------------ #

$ccNN = ''
$ccRR = $PSStyle.Reset
$ccOB = $PSStyle.Foreground.Cyan
$ccHC = $PSStyle.Foreground.Blue
$ccAC = $PSStyle.Foreground.Green
$ccIT = $PSStyle.Foreground.White
$ccEM = $PSStyle.Foreground.Yellow
$ccYC = $PSStyle.Foreground.Magenta
$ccIB = $PSStyle.Foreground.BrightBlue
$ccHI = $PSStyle.Foreground.BrightCyan
$ccSU = $PSStyle.Foreground.BrightGreen
$ccGR = $PSStyle.Foreground.BrightBlack
$ccMS = $PSStyle.Foreground.BrightWhite
$ccWA = $PSStyle.Foreground.BrightYellow
$ccXA = $PSStyle.Reset + $PSStyle.Foreground.Yellow
$ccXB = $PSStyle.Italic + $PSStyle.Foreground.Yellow

$Greeting = @"
    ┌────────────$($ccNN)$($ccNN)──────────────────────────────────────────────$($ccNN)$($ccNN)────────────────────┐
    │            $($ccNN)$($ccNN)                                              $($ccNN)$($ccNN)                    │
    │            $($ccIB)$($ccNN)$($ccNN)┌────────────────────────────────────────────────────┐$($ccOB)            │
    │            $($ccIB)$($ccNN)$($ccNN)│                                                    │$($ccOB)            │
    │            $($ccIB)│             $($ccMS)Music Directory Sort-a-bot$($ccIB)             │$($ccOB)            │
    │            $($ccIB)$($ccNN)$($ccNN)│                                                    │$($ccOB)            │
    │            $($ccIB)$($ccNN)$($ccNN)└────────────────────────────────────────────────────┘$($ccOB)            │
    │            $($ccNN)$($ccNN)                                              $($ccNN)$($ccNN)                    │
    └────────────$($ccNN)$($ccNN)──────────────────────────────────────────────$($ccNN)$($ccNN)────────────────────┘
"@

$Usagemsg = @"
    ┌────────$($ccNN)$($ccNN)──────────────────────────────────────────────────────$($ccNN)$($ccNN)────────────────┐
    │        $($ccNN)$($ccNN)                                                      $($ccNN)$($ccNN)                │
    │            $($ccIB)┌────────────────────────────────────────────────────┐$($ccOB)$($ccNN)$($ccNN)            │
    │            $($ccIB)│                                                    │$($ccOB)            │
    │            $($ccIB)│                 $($ccMS)Usage Instructions$($ccIB)                 │$($ccOB)            │
    │            $($ccIB)│                                                    │$($ccOB)            │
    │            $($ccIB)│    $($ccIT)SYNTAX$($ccIB)                                          │$($ccOB)            │
    │            $($ccIB)│                                                    │$($ccOB)            │
    │            $($ccIB)│    $($ccMS)> zz.musicsort.ps1 [[help | info] | [start]]$($ccIB)    │$($ccOB)            │
    │            $($ccIB)│                                                    │$($ccOB)            │
    │            $($ccIB)│    $($ccMS)- help | info$($ccIB)                                   │$($ccOB)            │
    │            $($ccIB)│                                                    │$($ccOB)            │
    │            $($ccIB)│    $($ccIT)Show some info, displays a short description$($ccIB)    │$($ccOB)            │
    │            $($ccIB)│    $($ccIT)of this script, and what it actually does.$($ccIB)      │$($ccOB)            │
    │            $($ccIB)│                                                    │$($ccOB)            │
    │            $($ccIB)│    $($ccMS)- start$($ccIB)                                         │$($ccOB)            │
    │            $($ccIB)│                                                    │$($ccOB)            │
    │            $($ccIB)│    $($ccIT)Use this command to actually run the script.$($ccIB)    │$($ccOB)            │
    │            $($ccIB)│    $($ccIT)Nothing will be done otherwise.$($ccIB)                 │$($ccOB)            │
    │            $($ccIB)│                                                    │$($ccOB)            │
    │            $($ccIB)└────────────────────────────────────────────────────┘$($ccOB)$($ccNN)$($ccNN)            │
    │        $($ccNN)$($ccNN)                                                      $($ccNN)$($ccNN)                │
    └────────$($ccNN)$($ccNN)──────────────────────────────────────────────────────────────$($ccNN)$($ccNN)────────┘
"@

$Info = @"
    ┌────────────$($ccNN)───────────────────────────────────────────────────────$($ccNN)───────────┐
    │            $($ccNN)                                                       $($ccNN)           │
    │            $($ccIT)Tired of the neverending mess in your music directory? $($ccGR)           │
    │            $($ccIT)Don't fret! Help is here!                              $($ccGR)           │
    │            $($ccIT)This simple script will bring order to your collection $($ccGR)           │
    │            $($ccIT)all at once, in one simple step!                       $($ccGR)           │
    │            $($ccIT)Just hop to your music collection directory, call this $($ccGR)           │
    │            $($ccIT)script and wait for it to finish. That's all! Yay!     $($ccGR)           │
    │            $($ccNN)                                                       $($ccNN)           │
    │            $($ccIT)NB: Hidden files and directories are silently ignored  $($ccGR)           │
    │            $($ccIT)    (With the exception of files in subdirectories)    $($ccGR)           │
    │            $($ccNN)                                                       $($ccNN)           │
    │            $($ccIT)> This script will perform the following steps:        $($ccGR)           │
    │            $($ccNN)                                                       $($ccNN)           │
    │            $($ccIT)- Enforces a consistent structure of the subdirectories$($ccGR)           │
    │            $($ccIT)- Puts non-music files into content-appropriate subdirs$($ccGR)           │
    │            $($ccIT)- Groups all other directories contained within subdirs$($ccGR)           │
    │            $($ccIT)- Attempts to sort directories based on name patterns  $($ccGR)           │
    │            $($ccIT)- Sieves out potentially misplaced or misnamed items   $($ccGR)           │
    │            $($ccIT)- Moves all files in the base directory into subdirs   $($ccGR)           │
    │            $($ccNN)                                                       $($ccNN)           │
    │            $($ccIT)PS: This script performs basic checks to avoid mis-use $($ccGR)           │
    │            $($ccIT)    like potentially running in a wrong location.      $($ccGR)           │
    │            $($ccIT)    It also is somewhat robust, e.g. sorting in an     $($ccGR)           │
    │            $($ccIT)    already sorted directory shouldn't break anything  $($ccGR)           │
    │            $($ccNN)                                                       $($ccNN)           │
    └────────────$($ccNN)───────────────────────────────────────────────────────$($ccNN)───────────┘
"@

$Warn = @"
    ┌───────────────────────────────────$($ccNN)$($ccNN)────────$($ccNN)$($ccNN)───────────────────────────────────┐
    │                                   $($ccNN)$($ccNN)        $($ccNN)$($ccNN)                                   │
    │                                   $($ccNN)$($ccWA)CAUTION!$($ccGR)$($ccNN)                                   │
    │                                   $($ccNN)$($ccNN)        $($ccNN)$($ccNN)                                   │
    │                $($ccEM)This script is $($ccXB)not$($ccXA) nondestructive, technically.$($ccGR)               │
    │                $($ccEM)It will not delete or change any files, but it$($ccGR)$($ccNN)$($ccNN)                │
    │                $($ccEM)will create new directories and move¹ some$($ccGR)$($ccNN)$($ccNN)                    │
    │                $($ccEM)files and directories around.$($ccGR)$($ccNN)$($ccNN)                                 │
    │                                   $($ccNN)$($ccNN)        $($ccNN)$($ccNN)                                   │
    │                $($ccEM)Please proceed with care and diligence.$($ccGR)$($ccNN)$($ccNN)                       │
    │                                   $($ccNN)$($ccNN)        $($ccNN)$($ccNN)                                   │
    │                $($ccGR)[¹]: Including moving and renaming (cf. 'mv')$($ccGR)$($ccNN)$($ccNN)                 │
    │                                   $($ccNN)$($ccNN)        $($ccNN)$($ccNN)                                   │
    │                $($ccYC)>  To confirm the execution of this script:  <$($ccGR)$($ccNN)$($ccNN)                │
    │                $($ccYC)>  Approve by responding with $($ccHI)CONFIRM$($ccYC) ...    <$($ccGR)                │
    │                                   $($ccNN)$($ccNN)        $($ccNN)$($ccNN)                                   │
    └───────────────────────────────────$($ccNN)$($ccNN)────────$($ccNN)$($ccNN)───────────────────────────────────┘
"@

$Epilogue = @"
    ┌────────────$($ccNN)─────────────$($ccNN)────────────────────────────$($ccNN)─────────────$($ccNN)────────────┐
    │            $($ccNN)             $($ccNN)                            $($ccNN)             $($ccNN)            │
    │            $($ccIB)┌────────────────────────────────────────────────────┐$($ccOB)$($ccNN)$($ccNN)            │
    │            $($ccIB)│                                                    │$($ccOB)$($ccNN)$($ccNN)            │
    │            $($ccIB)│            $($ccSU)Yay, everything is finished!$($ccIB)            │$($ccOB)            │
    │            $($ccIB)│                                                    │$($ccOB)$($ccNN)$($ccNN)            │
    │            $($ccIB)└────────────────────────────────────────────────────┘$($ccOB)$($ccNN)$($ccNN)            │
    │            $($ccNN)                                                      $($ccNN)$($ccNN)$($ccNN)            │
    └────────────$($ccNN)─────────────$($ccNN)────────────────────────────$($ccNN)─────────────$($ccNN)────────────┘
"@

$Noopexit = @"
    ┌────────────$($ccNN)─────────────$($ccNN)────────────────────────────$($ccNN)─────────────$($ccNN)────────────┐
    │            $($ccNN)             $($ccNN)                            $($ccNN)             $($ccNN)            │
    │        $($ccIB)┌────────────────────────────────────────────────────────────┐$($ccOB)$($ccNN)$($ccNN)        │
    │        $($ccIB)│                                                            │$($ccOB)$($ccNN)$($ccNN)        │
    │        $($ccIB)│ $($ccMS)No Confirmation! The script exited without doing anything!$($ccIB) │$($ccOB)        │
    │        $($ccIB)│                                                            │$($ccOB)$($ccNN)$($ccNN)        │
    │        $($ccIB)└────────────────────────────────────────────────────────────┘$($ccOB)$($ccNN)$($ccNN)        │
    │            $($ccNN)                                                      $($ccNN)$($ccNN)$($ccNN)            │
    └────────────$($ccNN)─────────────$($ccNN)────────────────────────────$($ccNN)─────────────$($ccNN)────────────┘
"@

# ------------------------------------------------------- End Text Outputs Section ------------------------------------------------------- #

# --------------------------------------------------------- Function Definitions --------------------------------------------------------- #

function Show-Error ([byte] $ErrCode) {
	switch ($ErrCode) {
		1 {$Msg = "The current working directory is not a valid path in a filesystem!"; break}
		2 {$Msg = "The target directory is empty! I can't work like that! Exiting now!"; break}
		3 {$Msg = "The target directory contains not enough subdirectories! Make sure to run the script in the right location."; break}
		4 {$Msg = "The target directory contains only one item?! Make sure to be in the right location and try to run it again."; break}
		5 {$Msg = "The target directory has not enough matching subdirectories. Apparently there is nothing to sort for now here?"; break}
	}
	$ErrorNote = [string]::Concat('[zz.musicsort] : ', 'Error -> ', $Msg)
	if ($ErrCode -gt 1) {
		$ErrorNote = [string]::Concat('    ', $ErrorNote)
		if ($ErrCode -gt 4) {
			$ErrorColr = 'DarkYellow'
		} else {
			$ErrorColr = 'DarkRed'
		}
	} else {
		$ErrorColr = 'Red'
	}
	Write-Host -Object $ErrorNote -ForegroundColor $ErrorColr
	exit $ErrCode
}

function Show-Info {
	Write-Host -Object $Greeting -ForegroundColor DarkCyan
	Write-Host -Object $Usagemsg -ForegroundColor DarkCyan
}

function Show-Help {
	Write-Host -Object $Greeting -ForegroundColor DarkCyan
	Write-Host -Object $Info -ForegroundColor DarkGray
}

function Switch-SessionState {
	param ([Parameter(Mandatory)][ValidateSet('Save', 'Change', 'Restore')][String] $Action)
	function Save-PSDriveState {
		$PSDrivesSaved = [Collections.Generic.List[Object]]::new(26)
		$CurrentFSList = Get-PSDrive -PSProvider FileSystem | Where-Object Name -like '?'
		foreach ($Entry in $CurrentFSList) {
			$FSPropertyMap = @{Drive = $Entry.Name; SavedLocation = $Entry.CurrentLocation}
			$PSDrivesSaved.Add($FSPropertyMap)
		}
		New-Variable -Name 'StoredPSDriveSet' -Value $PSDrivesSaved -Option ReadOnly -Scope 'Script'
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
		New-Variable -Name 'ErrActPrefSaved' -Value $ErrorActionPreference -Option ReadOnly -Scope 'Script'
		New-Variable -Name 'ConfrmPrefSaved' -Value $ConfirmPreference -Option ReadOnly -Scope 'Script'
		New-Variable -Name 'PresentLocation' -Value (Get-Location) -Option ReadOnly -Scope 'Script'
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

function Test-Directory ($Location) {
	if ((Get-Item -LiteralPath $Location) -isnot [IO.DirectoryInfo]) {
		return $false
	}
	else {
		return (Test-Path -LiteralPath $Location -PathType Container)
	}
}

function Test-IrregAttrib ([IO.FileSystemInfo] $TestItem) {
	if (
		$TestItem.Attributes.HasFlag([IO.FileAttributes]::Hidden)          -or
		$TestItem.Attributes.HasFlag([IO.FileAttributes]::System)          -or
		$TestItem.Attributes.HasFlag([IO.FileAttributes]::Offline)         -or
		$TestItem.Attributes.HasFlag([IO.FileAttributes]::Temporary)       -or
		$TestItem.Attributes.HasFlag([IO.FileAttributes]::Encrypted)       -or
		$TestItem.Attributes.HasFlag([IO.FileAttributes]::SparseFile)      -or
		$TestItem.Attributes.HasFlag([IO.FileAttributes]::Compressed)      -or
		$TestItem.Attributes.HasFlag([IO.FileAttributes]::NoScrubData)     -or
		$TestItem.Attributes.HasFlag([IO.FileAttributes]::ReparsePoint)    -or
		$TestItem.Attributes.HasFlag([IO.FileAttributes]::IntegrityStream)
	) {
		return $true
	}
	else {
		return $false
	}
}

function Test-NamePattern ([string] $TestString, [switch] $ReturnPattern) {
	foreach ($PatternEntry in $SetDirPattrn) {
		if ($TestString -like $PatternEntry) {
			if ($ReturnPattern) {
				return $PatternEntry
			}
			return $true
		}
	}
	return $false
}

function Clean-NameStrg ([string] $MutabString, [switch] $Harmonize) {
	$CharsToClean = '-', '_'
	$SeprsToCount = ' ', '_', '-', '.'
	function Count-SepChar ([string] $TestString, [char] $Sep) {
		$Cntr = [UInt16] 0
		for ($c = 0; $c -lt $TestString.Length; $c++) {
			if ($TestString[$c] -eq $Sep) {$Cntr++}
		}
		return $Cntr
	}
	while ($MutabString.Substring(0,1) -in $CharsToClean) {
		$MutabString = $MutabString.Remove(0,1)
	}
	while ($MutabString.Substring($MutabString.Length - 1) -in $CharsToClean) {
		$MutabString = $MutabString.Remove($MutabString.Length - 1)
	}
	if ($Harmonize -ne $true) {
		return $MutabString
	}
	else {
		$SelectedSepChar = '_'
		$SeprsObjectList = [Collections.Generic.List[Object]]::new($SeprsToCount.Count)
		foreach ($Entry in $SeprsToCount) {
			$EntryCount = Count-SepChar $MutabString $Entry
			$SeprCntObj = @{SepChar = $Entry; SepCharCount = $EntryCount}
			$SeprsObjectList.Add($SeprCntObj)
		}
		$MostLikelySepChar = ($SeprsObjectList | Sort-Object -Property 'SepCharCount' -Descending -Top 1)['SepChar']
		if ($MostLikelySepChar -eq $SelectedSepChar) {
			$HarmoniStrg = $MutabString
		}
		else {
			$HarmoniStrg = $MutabString.Replace($MostLikelySepChar, $SelectedSepChar)
		}
		return $HarmoniStrg
	}
}

function Create-NameSetCategories ($Refdir, $NameSet) {
	Push-Location -LiteralPath $Refdir
	foreach ($DirName in $NameSet) {
		if (-not (Test-Path -LiteralPath $DirName -PathType Container)) {
			New-Item -Name $DirName -ItemType 'Directory'
		}
	}
	Pop-Location
}

function Sort-MisnamedDirectories ($Refdir) {
	Push-Location -LiteralPath $Refdir
	$TestSet = Get-ChildItem -Directory | Where-Object {-not $_.Name.StartsWith('+')}
	foreach ($Dir in $TestSet) {
		if (($Dir.Name.Substring(0,1) -in $InvalidChars) -or ($Dir.Name.Substring($Dir.Name.Length - 1) -in $InvalidChars)) {
			Move-Item -Path $Dir -Destination (Convert-Path '+Issues')
		}
	}
	Pop-Location
}

function Move-FilesFromBaseToCtgr ($Refdir) {
	Push-Location -LiteralPath $Refdir
	$FileSet = Get-ChildItem -File
	if (($FileSet | Measure-Object).Count -gt 1) {
		$BasList = [Collections.Generic.List[Object]]::new($FileSet)
		$BaseCtgrAssc.GetEnumerator() | ForEach-Object {
			$SetName = $_.key
			$ExtsSet = Get-Variable -Name $_.value -ValueOnly
			for ($i = 0; $i -lt $BasList.Count; $i++) {
				if ($BasList[$i].Extension -in $ExtsSet) {
					Move-Item -Path $BasList[$i] -Destination (Convert-Path $SetName)
					$BasList.RemoveAt($i)
					$i--
				}
			}
		}
		if ($BasList.Count -ge 1) {
			Move-Item -Path $BasList -Destination (Convert-Path '+Issues')
		}
	}
	elseif ($null -ne $FileSet) {
		Move-Item -Path $FileSet -Destination (Convert-Path '+Issues')
	}
	Pop-Location
}

function Sort-ExtraSubDirMisnamed ($Refdir) {
	Push-Location -LiteralPath $Refdir
	$SusItms = [UInt] 0
	$TestSet = Get-ChildItem -Force
	foreach ($Itm in $TestSet) {
		if (($Itm.BaseName.Substring(0,1) -in $InvalidChars) -or ($Itm.BaseName.Substring($Itm.BaseName.Length - 1) -in $InvalidChars)) {
			Move-Item -Path $Itm -Destination (Convert-Path (Join-Path '..' '+Issues'))
			$SusItms += 1
		}
		if (Test-IrregAttrib $Itm) {
			Move-Item -Path $Itm -Destination (Convert-Path (Join-Path '..' '+Issues'))
			$SusItms += 1
		}
		if (($Itm.PSIsContainer) -and ($Itm.Name -notin $SubsDirCtgrs)) {
			Move-Item -Path $Itm -Destination (Convert-Path 'Meta')
		}
	}
	Pop-Location
	if ($SusItms -gt 0) {
		$SusItmsMsg = ($SusItms -gt 1) ? "suspicious elements have" : "suspicious element has"
		$LogfileMsg = [string]::Concat(
						"$((Get-Date).ToString())`n-------------------`nIssue:`nWhile processing a music set sub",
						"directory either invalidly named items, hidden items, or items with unexpected attributes have been found!`n`n",
						"Name of the processed directory:`n$($Refdir)`n`nResult:`n$SusItms $SusItmsMsg been dumped into the '+Issues' ",
						"category directory.`n-------------------`n")
		Add-Content -Path (Join-Path '.' '+Issues' 'Issuelog_Subdirectories.txt') -Value $LogfileMsg
	}
}

function Move-UnwantedFilesSubDir ($Refdir) {
	Push-Location -LiteralPath $Refdir
	$MoveDir, $SusExts = $false, [UInt] 0
	$FileSet = Get-ChildItem -File -Force
	if (($FileSet | Measure-Object).Count -gt 1) {
		$SubList = [Collections.Generic.List[Object]]::new($FileSet)
		$SubsCtgrAssc.GetEnumerator() | ForEach-Object {
			$SetName = $_.key
			$ExtsSet = Get-Variable -Name $_.value -ValueOnly
			for ($i = 0; $i -lt $SubList.Count; $i++) {
				if ($SubList[$i].Extension -in $ExtsSet) {
					Move-Item -Path $SubList[$i] -Destination (Convert-Path $SetName)
					$SubList.RemoveAt($i)
					$i--
				}
			}
		}
		for ($j = 0; $j -lt $SubList.Count; $j++) {
			if (($SubList[$j].Extension -notin $FileExtsAudi) -or ($SubList[$j].Extension -eq '')) {
				if (-not (Test-Path -Path (Join-Path '..' '+Issues' $SubList[$j].Name))) {
					Move-Item -Path $SubList[$j] -Destination (Convert-Path (Join-Path '..' '+Issues'))
				}
				else {
					$NamePrefix = [string]::Concat((New-Guid).Guid.Substring(0,8), '__-__')
					$NewItmName = "$NamePrefix$($SubList[$j].Name)"
					Rename-Item -Path $SubList[$j] -NewName $NewItmName
					Move-Item -Path $NewItmName -Destination (Convert-Path (Join-Path '..' '+Issues'))
				}
				$SusExts += 1
			}
		}
	}
	elseif (($FileSet | Measure-Object).Count -eq 1) {
		$LogfileMsg = [string]::Concat(
						"$((Get-Date).ToString())`n-------------------`nIssue:`nEncountered a directory with only one file!`n",
						"`nName of the directory:`n$($FileSet.Directory.Name)`n`nName of the file:`n$($FileSet.Name)`n`nResult:`n",
						"The file and the directory have been moved into the '+Issues' category directory.`n-------------------`n")
		Add-Content -Path (Join-Path '..' '+Issues' 'Issuelog_Subdirectories.txt') -Value $LogfileMsg
		$MoveDir = $true
	}
	else {
		$LogfileMsg = [string]::Concat(
						"$((Get-Date).ToString())`n-------------------`nIssue:`nEncountered an empty directory!`n",
						"`nName of the directory:`n$($Refdir)`n`nResult:`nThe empty directory has been moved into",
						" the '+Issues' category directory.`n-------------------`n")
		Add-Content -Path (Join-Path '..' '+Issues' 'Issuelog_Subdirectories.txt') -Value $LogfileMsg
		$MoveDir = $true
	}
	Pop-Location
	if ($SusExts -gt 0) {
		$SusExtsMsg = ($SusExts -gt 1) ? "suspicious elements have" : "suspicious element has"
		$LogfileMsg = [string]::Concat(
						"$((Get-Date).ToString())`n-------------------`nIssue:`nEncountered a music set ",
						"subdirectory which contained unexpected file types!`n`nName of the processed directory:`n$($Refdir)`n`n",
						"Result:`n$SusExts $SusExtsMsg been dumped into the '+Issues' category directory.`n-------------------`n")
		Add-Content -Path (Join-Path '.' '+Issues' 'Issuelog_Subdirectories.txt') -Value $LogfileMsg
	}
	if ($MoveDir) {
		Move-Item -Path $Refdir -Destination (Convert-Path '+Issues')
	}
}

function Sort-PatternSelectedDirs ($Refdir, [switch] $HarmonizeFileNames) {
	Push-Location -LiteralPath $Refdir
	$TestSet = Get-ChildItem -Directory | Where-Object {-not $_.Name.StartsWith('+')}
	foreach ($Dir in $TestSet) {
		if (Test-NamePattern $Dir.Name) {
			if ($HarmonizeFileNames) {
				Push-Location -LiteralPath $Dir.Name
				$FileSet = Get-ChildItem -File
				foreach ($File in $FileSet) {
					$NewFileName = Clean-NameStrg $File.BaseName -Harmonize
					Rename-Item -Path $File -NewName $NewFileName
				}
				Pop-Location
			}
			Move-Item -Path $Dir -Destination (Convert-Path '+Uns')
		}
	}
	Pop-Location
}

function Sort-FinishedDirectories ($Refdir) {
	Push-Location -LiteralPath (Convert-Path (Join-Path $Refdir '+Uns'))
	$SortSet = Get-ChildItem -Directory | Where-Object {-not $_.Name.StartsWith('+')}
	foreach ($Dir in $SortSet) {
		if (Test-NamePattern $Dir.Name) {
			$InitialName = $Dir.Name
			$PatternStrg = (Test-NamePattern $InitialName -ReturnPattern) -replace '\*', ''
			$ContStrings = $InitialName -split $PatternStrg, 2, 'SimpleMatch'
			$Interpret = Clean-NameStrg $ContStrings[0] -Harmonize
			$MusicSetd = Clean-NameStrg $ContStrings[1] -Harmonize
			$IntDirPth = Join-Path $Refdir $Interpret
			$SetDirPth = Join-Path $IntDirPth $MusicSetd
			if (-not (Test-Path -LiteralPath $IntDirPth -PathType Container)) {
				New-Item -Path $IntDirPth -ItemType 'Directory'
			}
			if (-not (Test-Path -LiteralPath $SetDirPth -PathType Container)) {
				Rename-Item -Path $InitialName -NewName $MusicSetd
				Move-Item -Path $MusicSetd -Destination $IntDirPth
			} else {
				$LogfileMsg = [string]::Concat(
								"$((Get-Date).ToString())`n-------------------`nIssue:`nA music set subdirectory with the same name has a",
								"lready been found!`n`nName of the already present directory:`n$($MusicSetd)`n`nContaining directory:`n",
								"$($Interpret)`n`nResult:`nThe currently processed (possible duplicate) directory has been moved into",
								" the '+Unt' category directory.`n-------------------`n")
				Add-Content -Path (Join-Path '..' '+Issues' 'Issuelog_PreviouslyExisting.txt') -Value $LogfileMsg
				if (-not (Test-Path -Path (Join-Path '..' '+Unt') -PathType Container)) {
					New-Item -Path (Join-Path '..' '+Unt') -ItemType 'Directory'
				}
				if (-not (Test-Path -Path (Join-Path '..' '+Unt' $InitialName) -PathType Container)) {
					Move-Item -Path $InitialName -Destination (Convert-Path (Join-Path '..' '+Unt'))
				} else {
					$NamePrefix = [string]::Concat((New-Guid).Guid.Substring(0,8), '__-__')
					$NewItmName = "$NamePrefix$InitialName"
					Rename-Item -Path $InitialName -NewName $NewItmName
					Move-Item -Path $NewItmName -Destination (Convert-Path (Join-Path '..' '+Unt'))
				}
			}
		}
	}
	Pop-Location
}

function Start-MusicSortSteps ($BaseDir) {
	$ContainedDirs = Get-ChildItem -Path $BaseDir -Directory
	$SubDirItemSet = $ContainedDirs | Where-Object {(-not ($_.Name.StartsWith('+'))) -and (Test-NamePattern $_.Name)}
	Create-NameSetCategories $BaseDir $BaseDirCtgrs
	Sort-MisnamedDirectories $BaseDir
	Move-FilesFromBaseToCtgr $BaseDir
	if ($null -ne $SubDirItemSet) {
		$SetSize = ($SubDirItemSet | Measure-Object).Count
		for ($i = 0; $i -lt $SetSize; $i++) {
			$DirObj = $SubDirItemSet[$i]
			$SubDir = $DirObj.FullName
			Create-NameSetCategories $SubDir $SubsDirCtgrs
			Sort-ExtraSubDirMisnamed $SubDir
			Move-UnwantedFilesSubDir $SubDir
			$ProgressParam = @{Activity        = "Fixing and moving all this chaos right now... Please be patient :)"
							   Status          = "Processing of $SetSize sub-directories: $($i + 1)"
							   PercentComplete = ((($i + 1) / $SetSize) * 100)}
			Write-Progress @ProgressParam
		}
		Sort-PatternSelectedDirs $BaseDir -HarmonizeFileNames
		Sort-FinishedDirectories $BaseDir
	}
	else {
		Show-Error 5
	}
}

# --------------------------------------------------------- Definitions Finished --------------------------------------------------------- #

# -------------------------------------------------------------- Begin Main -------------------------------------------------------------- #

function Check-Start ($BaseDir) {
	if (Test-Directory $BaseDir) {
		$BaseDirContent = Get-ChildItem -Path $BaseDir
		if ($null -eq $BaseDirContent) {
			Show-Error 2
		}
		switch ($BaseDirContent) {
			{($_ | Where-Object {$_.PSIsContainer} | Measure-Object).Count -le 2} {Show-Error 3}
			{($_ -is [IO.FileSystemInfo])}                                        {Show-Error 4}
		}
		Start-MusicSortSteps $BaseDir
	}
	else {
		Show-Error 1
	}
}

function Start-Run {
	Switch-SessionState -Action 'Change'
	Write-Host -Object $Greeting -ForegroundColor DarkCyan
	Write-Host -Object $Warn -ForegroundColor DarkGray
	$ConfirmVar = Read-Host -Prompt '    '
	if ($ConfirmVar -eq 'confirm') {
		Check-Start (Get-Location)
		Write-Host -Object $Epilogue -ForegroundColor DarkCyan
	}
	else {
		Write-Host -Object $Noopexit -ForegroundColor DarkCyan
	}
	Switch-SessionState -Action 'Restore'
}

if ($PWD.Provider.Name -cne 'FileSystem') {Show-Error 1}

switch ($RunMode) {
	'norun' {Show-Info; break}
	'infos' {Show-Help; break}
	'start' {Start-Run; break}
}

# --------------------------------------------------------------- End Main --------------------------------------------------------------- #

if ($RunMode -eq 'start') {
	$FinishMsg = "    [zz.musicsort] : Music Directory Sort-a-bot is $($PSStyle.Underline)$($PSStyle.Foreground.Green)DONE$($PSStyle.Reset)"
	Write-Host -Object $FinishMsg -ForegroundColor White
}

