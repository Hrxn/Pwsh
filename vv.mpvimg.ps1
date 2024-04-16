if (($null -eq $args[0]) -or ($null -eq $args[1])) {
	Write-Output '[vv.mpvimg] Usage: vv.mpvimg.ps1 <filename> <start position in seconds> [<duration to process in seconds>]'
} else {
	$File = Get-Item $args[0]
	$Name = $File.BaseName
	$tcst = $args[1]
	if ($null -ne $args[2]) {
		$tcen = $args[1] + $args[2]
	} else {
		$tcen = $args[1] + 2
	}
	if (Test-Path -LiteralPath $Name -PathType Container) {
		Write-Output "[vv.mpvimg] Info: Deleting previously existing directory `"$Name`" ... "
		Remove-Item -LiteralPath $Name -Recurse -Force
	}
	New-Item -Path '.' -Name $Name -ItemType 'Directory' | Out-Null
	$vo_image_opts = '--load-auto-profiles=no', '--vo-image-format=png', '--vo-image-png-compression=0', '--vo-image-tag-colorspace=yes', '--vo-image-high-bit-depth=yes'
	& mpv --no-audio --fs --vo=image $vo_image_opts --vo-image-outdir=$Name --start=$tcst --end=$tcen $File
}
