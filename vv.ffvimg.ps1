if ($args.Count -lt 2) {
	Write-Host "[vv.ffvimg] Usage: vv.ffvimg.ps1 <filename> <start position in seconds> [<duration to process in seconds>]"
} else {
	$File = Get-Item $args[0]
	$Dirn = "$($File.BaseName)-Images"
	$tcst = $args[1]
	if ($args.Count -eq 3) {
		$tcen = $args[2]
	} else {
		$tcen = 2
	}
	if (Test-Path -LiteralPath $Dirn -PathType Container) {
		Write-Host "[vv.ffvimg] Info: Deleting previously existing directory ""$Dirn"" ..."
		Remove-Item -LiteralPath $Dirn -Recurse -Force
	}
	New-Item -Path '.' -Name $Dirn -ItemType 'Directory'
	& ffmpeg -hide_banner -ss $tcst -t $tcen -i $File -c:v png ./$Dirn/%08d.png
}
