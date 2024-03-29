<#PSScriptInfo

.VERSION 1.2

.GUID 85df0f35-5565-4b50-b0ce-c9c3b92ed0b0

.AUTHOR hrxn.public@gmail.com

.COPYRIGHT (c)Hrxn

.TAGS gallery-dl downloader helper

.LICENSEURI https://github.com/Hrxn/Pwsh/blob/master/LICENSE

.PROJECTURI https://github.com/Hrxn/Pwsh

.RELEASENOTES
	- 1.2 [2023-12-22] | Add 'SourceRepository' option, allows running gallery-dl from source code (requires Python interpreter)
	- 1.1 [2023-02-02] | Add clipboard mode, Add 'gallery-dl input as batch' option
	- 1.0 [2023-01-03] | Initial release
#>

<#
.SYNOPSIS
	gallery-dl runner script

.DESCRIPTION
	gallery-dl companion script in PowerShell for quick and easy command-line usage.

	Dependencies:
	1) gallery-dl (https://github.com/mikf/gallery-dl)
	2) '-SourceRepository' option requires Python (https://www.python.org/)

.PARAMETER UrlToProcess
	URL(s) to be handed over to gallery-dl.

.PARAMETER Options
	Additional command-line options to provide for gallery-dl (to be specified in PowerShell array syntax).

.PARAMETER SourceRepository
	Path to a local source code repository of gallery-dl. Runs via Python interpreter if a value is given.

.PARAMETER InteractiveMode
	Use to start the interactive mode of this script (this mode takes precedence over other mode options).

.PARAMETER ClipboardMode
	Use to read input from the system clipboard instead of the command-line.

.PARAMETER BatchAll
	Use to activate batch mode, all input is handed over to gallery-dl in a single invocation.

.EXAMPLE
	dl.gallery-dl <URL-#1>, <URL-#2>

.EXAMPLE
	dl.gallery-dl -InteractiveMode

.INPUTS
	None. You cannot pipe objects to dl.gallery-dl.ps1.

.OUTPUTS
	None. dl.gallery-dl.ps1 does not generate any output.

.LINK
	https://github.com/Hrxn/pwsh
#>

#Requires -Version 7.0

[CmdletBinding(PositionalBinding = $false)]

param(
	[Parameter(Position = 0, ValueFromRemainingArguments)]
	[String[]] $UrlToProcess,

	[String[]] $Options,

	[String] $SourceRepository,

	[Switch] $InteractiveMode,

	[Switch] $ClipboardMode,

	[Switch] $BatchAll
)

$SlfName = 'dl.gallery-dl'
$AppName = 'gallery-dl'

$ccHigh, $ccCats, $ccExce, $ccErro, $ccSccs = "`e[97m", "`e[90m", "`e[91m", "`e[31m", "`e[92m"
$ccWarn, $ccInfo, $ccShft, $ccEmph, $ccZero = "`e[33m", "`e[94m", "`e[34m", "`e[35m", "`e[0m"

# ------ Functions ---------------------------------------------------------------------------------------------------------------------------------------------

function Show-Status ([String] $ID, [String[]] $Text, [Byte] $Exit) {
	switch ($ID) {
		{$_.StartsWith('inf')} {$ccCC = $ccInfo; break}
		{$_.StartsWith('wrn')} {$ccCC = $ccWarn; break}
		{$_.StartsWith('err')} {$ccCC = $ccErro; break}
		{$_.StartsWith('exc')} {$ccCC = $ccExce; break}
		{$_.StartsWith('emp')} {$ccCC = $ccEmph; break}
		{$_.StartsWith('suc')} {$ccCC = $ccSccs; break}
	}
	switch ($ID) {
		'exc-fn-no-targetcmd' { $Msg =
			" ${ccCC}Exception${ccZero} : Unable to run this script because of a ${ccWarn}dependency error${ccZero}! The dependency " +
			"${ccShft}'${ccHigh}$($Text[0])${ccShft}'${ccZero} is not available or accessible on the local system!"
			$CustomOutput = $false; break
		}
		'exc-fn-invalid-path' { $Msg =
			" ${ccCC}Exception${ccZero} : Unable to run this script because of an ${ccWarn}invalid path${ccZero} that has been given! " +
			"${ccShft}'${ccHigh}$($Text[0])${ccShft}'${ccZero} does not contain a source code repository of gallery-dl!"
			$CustomOutput = $false; break
		}
		'err-fn-batch-errors' { $Msg =
			"   ${ccCC}Error${ccZero}   : The exit code returned by ${ccShft}'${ccHigh}$($AppName)${ccShft}'${ccZero} indicates " +
			"some potential issues. Please check your logs for details!"
			$CustomOutput = $false; break
		}
		'err-fn-invalid-entr' { $Msg =
			"   ${ccCC}Error${ccZero}   : There has been a discrepancy, ${ccShft}'${ccHigh}$($SlfName)${ccShft}'${ccZero} received " +
			"an input set of ${ccShft}'${ccHigh}$($Text[1])${ccShft}'${ccZero} values, but only ${ccShft}'" +
			"${ccHigh}$($Text[0])${ccShft}'${ccZero} entries have been proper URLs, apparently!"
			$CustomOutput = $false; break
		}
		'err-op-return-error' { $Msg =
			"   ${ccCC}Error${ccZero}   : The exit code returned by ${ccShft}'${ccHigh}$($AppName)${ccShft}'${ccZero} indicates " +
			"an issue. Please see the line above!"
			$CustomOutput = $false; break
		}
		'err-ln-entry-failed' { $Msg =
			"   ${ccCC}Error${ccZero}   : The URL ${ccShft}'${ccHigh}$($Text[0])${ccShft}'${ccZero} caused an error with " +
			"${ccShft}'${ccHigh}$($AppName)${ccShft}'${ccZero}! Check your logs!"
			$CustomOutput = $false; break
		}
		'wrn-op-skipping-url' { $Msg =
			"  ${ccCC}Warning${ccZero}  : The element being currently processed (${ccShft}'${ccHigh}$($Text[0])${ccShft}'" +
			"${ccZero}) does not appear to be a valid URL! Skipping this entry!"
			$CustomOutput = $false; break
		}
		'wrn-op-improper-url' { $Msg =
			"  ${ccCC}Warning${ccZero}  : The received input (${ccShft}'${ccHigh}$($Text[0])${ccShft}'${ccZero}) does not appear " +
			"to be a valid URL! Please try again!"
			$CustomOutput = $false; break
		}
		'emp-fn-empty-invals' { $Msg =
			"    ${ccCC}Note${ccZero}   : ${ccShft}'${ccHigh}$($SlfName)${ccShft}'${ccZero} could not read any values via standard input" +
			", was anything pasted into the terminal at all?"
			$CustomOutput = $false; break
		}
		'emp-fn-empty-clipcn' { $Msg =
			"    ${ccCC}Note${ccZero}   : ${ccShft}'${ccHigh}$($SlfName)${ccShft}'${ccZero} could not read anything from the system " +
			"clipboard, please make sure that the clipboard is not empty!"
			$CustomOutput = $false; break
		}
		'emp-fn-exits-notify' { $Msg =
			"    ${ccCC}Note${ccZero}   : ${ccShft}'${ccHigh}$($SlfName)${ccShft}'${ccZero} made it through a " +
			"batch of ${ccShft}'${ccHigh}$($Text[0])${ccShft}'${ccZero} URLs, but exit codes returned by " +
			"${ccShft}'${ccHigh}$($AppName)${ccShft}'${ccZero} indicate issues. Please " +
			"check the logs of ${ccShft}'${ccHigh}$($AppName)${ccShft}'${ccZero}!"
			$CustomOutput = $false; break
		}
		'suc-fn-exits-intera' { $Msg =
			"  ${ccCC}Success${ccZero}  : No more input URLs to feed for ${ccShft}'${ccHigh}$($AppName)${ccShft}'${ccZero} it seems, " +
			"exiting this script just now ..."
			$CustomOutput = $false; break
		}
		'suc-fn-exits-pastes' { $Msg =
			"  ${ccCC}Success${ccZero}  : All done, yay! ${ccShft}'${ccHigh}$($SlfName)${ccShft}'${ccZero} has successfully processed " +
			"the entire batch of ${ccShft}'${ccHigh}$($Text[0])${ccShft}'${ccZero} URLs!"
			$CustomOutput = $false; break
		}
		'suc-op-success-done' { $Phrase = $Options ? 'Task is done' : 'Download is done'
			$Msg = "  ${ccCC}Success${ccZero}  : $Phrase, ${ccShft}'${ccHigh}$($AppName)${ccShft}'${ccZero} has successfully completed " +
			"its operation for the entered URL!"
			$CustomOutput = $false; break
		}
		'suc-fn-batch-finish' { $Msg =
			"  ${ccCC}Success${ccZero}  : All done, yay! ${ccShft}'${ccHigh}$($SlfName)${ccShft}'${ccZero} has successfully processed " +
			"the entire clipboard content of ${ccShft}'${ccHigh}$($Text[0])${ccShft}'${ccZero} URLs!"
			$CustomOutput = $false; break
		}
		'suc-ln-entry-finish' { $Msg =
			"  ${ccCC}Success${ccZero}  : The URL ${ccShft}'${ccHigh}$($Text[0])${ccShft}'${ccZero} has been succesfully processed by " +
			"${ccShft}'${ccHigh}$($AppName)${ccShft}'${ccZero}!"
			$CustomOutput = $false; break
		}
		'inf-op-start-argval' { $Msg =
			"    ${ccCC}Info${ccZero}   : There have been ${ccShft}'${ccHigh}$($Text[0])${ccShft}'${ccZero} values passed on to " +
			"${ccShft}'${ccHigh}$($SlfName)${ccShft}'${ccZero} as arguments, starting to process these just now ..."
			$CustomOutput = $false; break
		}
		'inf-op-start-multln' { $Msg =
			"    ${ccCC}Info${ccZero}   : ${ccShft}'${ccHigh}$($SlfName)${ccShft}'${ccZero} has been able to find " +
			"${ccShft}'${ccHigh}$($Text[0])${ccShft}'${ccZero} pasted entries, starting to process these just now ..."
			$CustomOutput = $false; break
		}
		'inf-op-start-clipin' { $Msg =
			"    ${ccCC}Info${ccZero}   : ${ccShft}'${ccHigh}$($SlfName)${ccShft}'${ccZero} was able to read " +
			"${ccShft}'${ccHigh}$($Text[0])${ccShft}'${ccZero} entries from the system clipboard, starting to process these just now ..."
			$CustomOutput = $false; break
		}
		'inf-ln-process-line' { $Msg =
			"    ${ccCC}Info${ccZero}   : Starting attempt at the following entry ... " +
			"$("${ccCats}[${ccInfo}{0,4}${ccCats} / ${ccSccs}{1,-4}${ccCats}]${ccZero}" -f $Text[0], $Text[1]) " +
			"(${ccShft}'${ccHigh}$($Text[2])${ccShft}'${ccZero})"
			$CustomOutput = $false; break
		}
		'inf-ln-entry-finish' { $Msg =
			"    ${ccCC}Info${ccZero}   : Completed processing of following entry ... " +
			"$("${ccCats}[${ccInfo}{0,4}${ccCats} / ${ccSccs}{1,-4}${ccCats}]${ccZero}" -f $Text[0], $Text[1]) " +
			"(${ccShft}'${ccHigh}$($Text[2])${ccShft}'${ccZero})"
			$CustomOutput = $false; break
		}
		'inf-fn-show-options' { $Msg =
			"    ${ccCC}Info${ccZero}   : The following options for gallery-dl have been set -> ${ccShft}'${ccHigh}$Text${ccShft}'${ccZero}."
			$CustomOutput = $false; break
		}
		'inf-op-mode-interac' {
			$InitialWidth = [Console]::WindowWidth - 2
			$Top = "${ccCC}$([string][char]9484)$([string][char]9472 * $InitialWidth)$([string][char]9488)`n"
			$Eml = "$([string][char]9474)$(' ' * $InitialWidth)$([string][char]9474)`n"
			$Bot = "$([string][char]9492)$([string][char]9472 * $InitialWidth)$([string][char]9496)${ccZero}"
			$Vis = "[$SlfName] Info : Starting Interactive Mode! :"
			if (($InitialWidth % 2) -eq 0) {
				$Wid, $Pad = ($InitialWidth / 2), 0
			} else {
				$Wid, $Pad = (($InitialWidth - 1) / 2), 1
			}
			if (($Vis.Length % 2) -eq 0) {
				$Ofl, $Ofr = ($Wid - ($Vis.Length / 2)), ($Wid - ($Vis.Length / 2))
			} else {
				$Ofl, $Ofr = ($Wid - (($Vis.Length + 1) / 2)), ($Wid - (($Vis.Length - 1) / 2))
			}
			$Cps = "$([string][char]9474)$(' ' * $Ofl)${ccCats}[${ccCC}$SlfName${ccCats}]${ccHigh} Info ${ccEmph}:${ccHigh} Starting " +
					"Interactive Mode!${ccEmph} :${ccCC}$(' ' * ($Ofr + $Pad))$([string][char]9474)"
			$Msg = [String]::Concat($Top, $Eml, $Cps, $Eml, $Bot)
			$CustomOutput = $true; break
		}
		'inf-op-mode-clipboa' {
			$InitialWidth = [Console]::WindowWidth - 2
			$Top = "${ccCC}$([string][char]9484)$([string][char]9472 * $InitialWidth)$([string][char]9488)`n"
			$Eml = "$([string][char]9474)$(' ' * $InitialWidth)$([string][char]9474)`n"
			$Bot = "$([string][char]9492)$([string][char]9472 * $InitialWidth)$([string][char]9496)${ccZero}"
			$Vis = "[$SlfName] Info : Reading Input From Clipboard! :"
			if (($InitialWidth % 2) -eq 0) {
				$Wid, $Pad = ($InitialWidth / 2), 0
			} else {
				$Wid, $Pad = (($InitialWidth - 1) / 2), 1
			}
			if (($Vis.Length % 2) -eq 0) {
				$Ofl, $Ofr = ($Wid - ($Vis.Length / 2)), ($Wid - ($Vis.Length / 2))
			} else {
				$Ofl, $Ofr = ($Wid - (($Vis.Length + 1) / 2)), ($Wid - (($Vis.Length - 1) / 2))
			}
			$Cps = "$([string][char]9474)$(' ' * $Ofl)${ccCats}[${ccCC}$SlfName${ccCats}]${ccHigh} Info ${ccEmph}:${ccHigh} Reading " +
					"Input From Clipboard!${ccEmph} :${ccCC}$(' ' * ($Ofr + $Pad))$([string][char]9474)"
			$Msg = [String]::Concat($Top, $Eml, $Cps, $Eml, $Bot)
			$CustomOutput = $true; break
		}
		'inf-op-mode-pasteln' {
			$InitialWidth = [Console]::WindowWidth - 2
			$Top = "${ccCC}$([string][char]9484)$([string][char]9472 * $InitialWidth)$([string][char]9488)`n"
			$Eml = "$([string][char]9474)$(' ' * $InitialWidth)$([string][char]9474)`n"
			$Bot = "$([string][char]9492)$([string][char]9472 * $InitialWidth)$([string][char]9496)${ccZero}"
			$Vis = "[$SlfName] Info : Starting Multiline Paste Mode! :"
			if (($InitialWidth % 2) -eq 0) {
				$Wid, $Pad = ($InitialWidth / 2), 0
			} else {
				$Wid, $Pad = (($InitialWidth - 1) / 2), 1
			}
			if (($Vis.Length % 2) -eq 0) {
				$Ofl, $Ofr = ($Wid - ($Vis.Length / 2)), ($Wid - ($Vis.Length / 2))
			} else {
				$Ofl, $Ofr = ($Wid - (($Vis.Length + 1) / 2)), ($Wid - (($Vis.Length - 1) / 2))
			}
			$Cps = "$([string][char]9474)$(' ' * $Ofl)${ccCats}[${ccCC}$SlfName${ccCats}]${ccHigh} Info ${ccEmph}:${ccHigh} Starting " +
					"Multiline Paste Mode!${ccEmph} :${ccCC}$(' ' * ($Ofr + $Pad))$([string][char]9474)"
			$Msg = [String]::Concat($Top, $Eml, $Cps, $Eml, $Bot)
			$CustomOutput = $true; break
		}
	}
	if ($CustomOutput) {
		$Output = $Msg
	} else {
		$Output = [String]::Concat("${ccCats}[${ccCC}$SlfName${ccCats}]${ccZero}", ' :', $Msg)
	}
	Write-Host -Object $Output
	if ($Exit) {
		exit $Exit
	}
}

function Show-Prompt {
	Write-Host -Object "${ccCats}[${ccHigh}$SlfName${ccCats}]${ccZero} :   Input   : Paste in a URL, or type '(e)xit' to exit: > " -NoNewline
	$UserInput = Read-Host
	return $UserInput.Trim()
}

function Invoke-Application ([String] $Task) {
	$AppArgs = [Collections.Generic.List[String]]::new()
	if ($Options) {
		foreach ($Entry in $Options) {
			$AppArgs.Add($Entry)
		}
	}
	$AppArgs.Add($Task)
	if (($AppPath | Measure-Object).Count -eq 2) {
		& $AppPath[0] $AppPath[1] $AppArgs
	} else {
		& $AppPath $AppArgs
	}
	$script:AppExitStatus = $?
}

function Invoke-Processing ([Array] $EntrySet) {
	$Count = $EntrySet.Count
	$Valid = [UInt32] 0
	if ($BatchAll) {
		$AppArgs = [Collections.Generic.List[String]]::new()
		if ($Options) {
			foreach ($Entry in $Options) {
				$AppArgs.Add($Entry)
			}
		}
		for ($i = 0; $i -lt $Count; $i++) {
			$Element = $EntrySet[$i]
			if ([Uri]::IsWellFormedUriString($Element, [UriKind]::Absolute)) {
				$Valid += 1
				$AppArgs.Add($Element)
			}
		}
		if (($AppPath | Measure-Object).Count -eq 2) {
			& $AppPath[0] $AppPath[1] $AppArgs
		} else {
			& $AppPath $AppArgs
		}
		$? ? (Show-Status -ID 'suc-fn-batch-finish' -Text $Count) : (Show-Status -ID 'err-fn-batch-errors')
		if ($Valid -lt $Count) {
			Show-Status -ID 'err-fn-invalid-entr' -Text @($Valid, $Count)
		}
	} else {
		$Issue = 0
		for ($i = 0; $i -lt $Count; $i++) {
			$Element = $EntrySet[$i]
			if ([Uri]::IsWellFormedUriString($Element, [UriKind]::Absolute)) {
				$Valid += 1
				Show-Status -ID 'inf-ln-process-line' -Text @(($i + 1), $Count, $Element)
				Invoke-Application -Task $Element
				if ($script:AppExitStatus) {
					Show-Status -ID 'suc-ln-entry-finish' -Text $Element
				} else {
					Show-Status -ID 'err-ln-entry-failed' -Text $Element
					$Issue = 1
				}
				Show-Status -ID 'inf-ln-entry-finish' -Text @(($i + 1), $Count, $Element)
			} else {
				Show-Status -ID 'wrn-op-skipping-url' -Text $Element
			}
		}
		if ($Valid -lt $Count) {
			$Issue = ($Issue -eq 1) ? 8 : 2
		}
		switch ($Issue) {
			1 { Show-Status -ID 'emp-fn-exits-notify' -Text $Count }
			2 { Show-Status -ID 'err-fn-invalid-entr' -Text @($Valid, $Count) }
			8 { Show-Status -ID 'err-fn-invalid-entr' -Text @($Valid, $Count); Show-Status -ID 'emp-fn-exits-notify' -Text $Count }
			0 { Show-Status -ID 'suc-fn-exits-pastes' -Text $Count }
		}
	}
}

function Invoke-InteractiveMode {
	do {
		$Entry = Show-Prompt
		if ($Entry -notmatch '(?i)^e[xit]*') {
			if ([Uri]::IsWellFormedUriString($Entry, [UriKind]::Absolute)) {
				Invoke-Application -Task $Entry
				if ($script:AppExitStatus) {
					Show-Status -ID 'suc-op-success-done'
				} else {
					Show-Status -ID 'err-op-return-error'
				}
			} else {
				Show-Status -ID 'wrn-op-improper-url' -Text $Entry
			}
			$InteractionLoop = $true
		} else {
			Show-Status -ID 'suc-fn-exits-intera'
			$InteractionLoop = $false
		}
	} while ($InteractionLoop)
}

function Invoke-MultilineMode {
	$StdIn = [Console]::In
	$Lines = [Collections.Generic.List[String]]::new()
	while ($Line = $StdIn.ReadLine()) {
		$Lines.Add($Line.Trim())
	}
	if ($Lines.Count -gt 0) {
		Show-Status -ID 'inf-op-start-multln' -Text $Lines.Count
		Invoke-Processing -EntrySet $Lines
	} else {
		Show-Status -ID 'emp-fn-empty-invals'
	}
}

function Invoke-ClipboardMode {
	$ClipIn = Get-Clipboard
	$ClipIn = foreach ($v in $ClipIn) { if (![String]::IsNullOrWhiteSpace($v)) { $v.Trim() } }
	$Amount = ($ClipIn | Measure-Object).Count
	if ($Amount -gt 0) {
		Show-Status -ID 'inf-op-start-clipin' -Text $Amount
		Invoke-Processing -EntrySet $ClipIn
	} else {
		Show-Status -ID 'emp-fn-empty-clipcn'
	}
}

# ------ Main --------------------------------------------------------------------------------------------------------------------------------------------------

if ($SourceRepository) {
	if (-not (Get-Command -Name 'python' -CommandType Application -ErrorAction Ignore -OutVariable CmdInfo)) {
		Show-Status -ID 'exc-fn-no-targetcmd' -Text 'python' -Exit 1
	} else {
		if (-not ($SourceRepository.EndsWith('gallery_dl') -or $SourceRepository.EndsWith('gallery_dl' + [IO.Path]::DirectorySeparatorChar))) {
			$SourceRepository = [IO.Path]::Join($SourceRepository, 'gallery_dl')
		}
		if (-not ([IO.Directory]::Exists([IO.Path]::GetFullPath($SourceRepository, $PWD.Path)))) {
			Show-Status -ID 'exc-fn-invalid-path' -Text ($SourceRepository -replace '[/\\]?gallery_dl[/\\]?','') -Exit 2
		} else {
			$AppPath = $CmdInfo[0].Path, [IO.Path]::GetFullPath($SourceRepository, $PWD.Path)
		}
	}
} else {
	if (-not (Get-Command -Name $AppName -CommandType Application -ErrorAction Ignore -OutVariable CmdInfo)) {
		Show-Status -ID 'exc-fn-no-targetcmd' -Text $AppName -Exit 1
	} else {
		$AppPath = $CmdInfo[0].Path
	}
}

if ($InteractiveMode) {
	Show-Status -ID 'inf-op-mode-interac'
	if ($Options) {
		Show-Status -ID 'inf-fn-show-options' -Text $Options
	}
	Invoke-InteractiveMode
} elseif ($ClipboardMode) {
	Show-Status -ID 'inf-op-mode-clipboa'
	if ($Options) {
		Show-Status -ID 'inf-fn-show-options' -Text $Options
	}
	Invoke-ClipboardMode
} elseif ($UrlToProcess) {
	Show-Status -ID 'inf-op-start-argval' -Text $UrlToProcess.Count
	if ($Options) {
		Show-Status -ID 'inf-fn-show-options' -Text $Options
	}
	Invoke-Processing -EntrySet $UrlToProcess
} else {
	Show-Status -ID 'inf-op-mode-pasteln'
	if ($Options) {
		Show-Status -ID 'inf-fn-show-options' -Text $Options
	}
	Invoke-MultilineMode
}

