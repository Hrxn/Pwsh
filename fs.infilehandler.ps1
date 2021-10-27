if (($args[0] -eq $null) -or ($args[1] -eq $null)) {
	Write-Host "[fs.infilehandler] Usage: fs.infilehandler.ps1 <INPUT-FILE> <PROCESSING-SCRIPT>"
	exit 1
}

if (-not (Test-Path -LiteralPath $args[0] -PathType Leaf)) {
	Write-Host "[fs.infilehandler] Given <INPUT-FILE> parameter could not be found as a file"
	exit 2
}

if (-not ((Get-Content $args[0]).Count -gt 0)) {
	Write-Host "[fs.infilehandler] Given <INPUT-FILE> has been found but seems to be empty"
	exit 3
}

if (-not (Get-Command $args[1])) {
	Write-Host "[fs.infilehandler] Given <PROCESSING-SCRIPT> command does not exist"
	exit 4
}

$File = (Get-Item $args[0]).FullName
$Size = (Get-Content $args[0]).Count
$Proc = (Get-Command $args[1]).Source
$Cntr = 0

foreach ($Read in [System.IO.File]::ReadLines($File)) {
	$Cntr += 1
	$Line = $Read.Trim()
	if (-not ($Line.StartsWith('#') -or [String]::IsNullOrWhiteSpace($Line) -or [String]::IsNullOrEmpty($Line))) {
		& $Proc $Line
	}
	Write-Progress -Activity "Infile handling in progress..." -Status "Processing of $Size entries - Done: $Cntr" -PercentComplete (($Cntr / $Size) * 100)
}

