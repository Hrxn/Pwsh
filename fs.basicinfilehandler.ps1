if ($args.Count -lt 2) {
	Write-Host "[fs.basicinfilehandler] Usage: fs.basicinfilehandler.ps1 <INPUT-FILE> <PROCESSING-SCRIPT>"
	exit 0
}

if (-not (Test-Path -LiteralPath $args[0] -PathType Leaf)) {
	Write-Host "[fs.basicinfilehandler] Given <INPUT-FILE> parameter could not be found as a file" -ForegroundColor DarkRed
	exit 1
}

if (-not ((Get-Content $args[0] | Measure-Object -Line).Lines -gt 0)) {
	Write-Host "[fs.basicinfilehandler] Given <INPUT-FILE> has been found but seems to be empty" -ForegroundColor DarkRed
	exit 2
}

if (-not (Get-Command -Name $args[1] -ErrorAction Ignore)) {
	Write-Host "[fs.basicinfilehandler] Given <PROCESSING-SCRIPT> command does not exist" -ForegroundColor DarkRed
	exit 3
}

$Size = (Get-Content $args[0] | Measure-Object -Line).Lines
$Proc = (Get-Command $args[1]).Source
$File = (Get-Item $args[0]).FullName
$Cntr = [UInt64] 0

foreach ($Read in [System.IO.File]::ReadLines($File)) {
	$Cntr += 1
	$Line = $Read.Trim()
	if (-not ($Line.StartsWith('#') -or $Line.StartsWith('-') -or [System.String]::IsNullOrEmpty($Line))) {
		& $Proc $Line
	}
	Write-Progress -Activity "Infile handling in progress..." -Status "Processing of $Size entries - Done: $Cntr" -PercentComplete (($Cntr / $Size) * 100)
}
