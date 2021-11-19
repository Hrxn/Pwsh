if (($args[0] -eq $null) -or ($args[1] -eq $null)) {
	Write-Host "[fs.ffvimg] Usage: fs.ffvimg.ps1 <filename> <start position in seconds> [<duration to process in seconds>]"
} else {
	$file = Get-Item $args[0]
	$name = $file.BaseName
	$tcst = $args[1]
	if ($args[2] -ne $null) {
		$tcen = $args[2]
	} else {
		$tcen = 2
	}
	if (Test-Path -LiteralPath $name -PathType Container) {
		Write-Host "[fs.ffvimg] Info: Deleting previously existing directory `"$name`" ... "
		Remove-Item -LiteralPath $name -Recurse -Force
	}
	New-Item -Path "." -Name $name -ItemType "Directory"
	& "ffmpeg.exe" -ss $tcst -t $tcen -i $file -c:v png ./$name/%08d.png
}

