if (($args[0] -eq $null) -or ($args[1] -eq $null)) {
	Write-Host "[fs.mpvimg] Usage: fs.mpvimg.ps1 <filename> <start position in seconds> [<duration to process in seconds>]"
} else {
	$file = Get-Item $args[0]
	$name = $file.BaseName
	$tcst = $args[1]
	if ($args[2] -ne $null) {
		$tcen = $args[2]
	} else {
		$tcen = $args[1] + 2
	}
	if (Test-Path -LiteralPath $name -PathType Container) {
		Write-Host "[fs.mpvimg] Info: Deleting previously existing directory `"$name`" ... "
		Remove-Item -LiteralPath $name -Recurse -Force
	}
	New-Item -Path "." -Name $name -ItemType "Directory"
	& "mpv.com" --no-audio --fs --vo=image --vo-image-format=png --vo-image-png-compression=0 --vo-image-tag-colorspace=yes --vo-image-high-bit-depth=yes --vo-image-outdir=$name --start=$tcst --end=$tcen $file
}

