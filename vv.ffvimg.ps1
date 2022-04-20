if ($args.Count -lt 2) {
	Write-Host "[vv.ffvimg] Usage: vv.ffvimg.ps1 <filename> <start position in seconds> [<duration to process in seconds>]"
} else {
	$File = Get-Item $args[0]
	$Name = $File.BaseName
	$tcst = $args[1]
	if ($args.Count -eq 3) {
		$tcen = $args[2]
	} else {
		$tcen = 2
	}
	if (Test-Path -LiteralPath $Name -PathType Container) {
		Write-Host "[vv.ffvimg] Info: Deleting previously existing directory `"$Name`" ... "
		Remove-Item -LiteralPath $Name -Recurse -Force
	}
	New-Item -Path '.' -Name $Name -ItemType 'Directory'
	& ffmpeg -hide_banner -ss $tcst -t $tcen -i $File -c:v png ./$Name/%08d.png
}
