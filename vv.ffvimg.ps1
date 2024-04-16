if (($null -eq $args[0]) -or ($null -eq $args[1])) {
	Write-Output '[vv.ffvimg] Usage: vv.ffvimg.ps1 <filename> <start position in seconds> [<duration to process in seconds>]'
} else {
	$File = Get-Item $args[0]
	$Name = $File.BaseName
	$tcst = $args[1]
	if ($null -ne $args[2]) {
		$tcen = $args[2]
	} else {
		$tcen = 2
	}
	if (Test-Path -LiteralPath $Name -PathType Container) {
		Write-Output "[vv.ffvimg] Info: Deleting previously existing directory `"$Name`" ... "
		Remove-Item -LiteralPath $Name -Recurse -Force
	}
	New-Item -Path '.' -Name $Name -ItemType 'Directory' | Out-Null
	& ffmpeg -ss $tcst -t $tcen -i $File -c:v png ./$Name/%08d.png
}
