if (($args[0] -eq $null) -or ($args[1] -eq $null)) {
	Write-Host "[vv.ffvimg] Usage: vv.ffvimg.ps1 <filename> <start position in seconds> [<duration to process in seconds>]"
} else {
	$File = Get-Item $args[0]
	$Name = $file.BaseName
	$tcst = $args[1]
	if ($args[2] -ne $null) {
		$tcen = $args[2]
	} else {
		$tcen = 2
	}
	if (Test-Path -LiteralPath $Name -PathType Container) {
		Write-Host "[vv.ffvimg] Info: Deleting previously existing directory `"$Name`" ... "
		Remove-Item -LiteralPath $Name -Recurse -Force
	}
	New-Item -Path "." -Name $Name -ItemType Directory
	& ffmpeg -ss $tcst -t $tcen -i $File -c:v png ./$name/%08d.png
}
