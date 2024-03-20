if ($args.Count -lt 2) {
	Write-Host "[vv.mpvimg] Usage: vv.mpvimg.ps1 <filename> <start position in seconds> [<duration to process in seconds>]"
} else {
	$File = Get-Item $args[0]
	$Dirn = "$($File.BaseName)-Images"
	$tcst = $args[1]
	if ($args.Count -eq 3) {
		$tcen = $args[2]
	} else {
		$tcen = $args[1] + 2
	}
	if (Test-Path -LiteralPath $Dirn -PathType Container) {
		Write-Host "[vv.mpvimg] Info: Deleting previously existing directory ""$Dirn"" ..."
		Remove-Item -LiteralPath $Dirn -Recurse -Force
	}
	New-Item -Path '.' -Name $Dirn -ItemType 'Directory'
	$vo_image_opts = '--vo-image-format=png','--vo-image-png-compression=0','--vo-image-tag-colorspace=yes','--vo-image-high-bit-depth=yes'
	& mpv --quiet --no-audio --fs --vo=image $vo_image_opts --vo-image-outdir=$Dirn --start=$tcst --end=$tcen $File
}
