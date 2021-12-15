param
(
	[String] $Command,
	[Switch] $Help
)

enum RunModeType {norun; infos; start}

$Infocmd = 'help', 'info', '--help', '?'
switch ($Command) {
	{$Command -eq 'start' -and (-not ($script:args.Count -gt 0))} {$RunMode = [RunModeType]::start}
	{$Command -in $Infocmd -or ($script:Help)}                    {$RunMode = [RunModeType]::infos}
	default                                                       {$RunMode = [RunModeType]::norun}
}


Write-Host -Object "[  -  ] The beginning, of this template-runmodes-switch.ps1 script file  .....  " -ForegroundColor 'DarkGray'

# Works also without string quotation marks in the switch conditions, because of implicit string type coercion, I think..
switch ($RunMode) {
	'norun' {Write-Host "   -    Incorrect parameter usage! | Display Info and Usage Message | $($PSStyle.Foreground.BrightCyan)command -> $command $($PSStyle.Reset)| $($PSStyle.Foreground.BrightCyan)args -> $args $($PSStyle.Reset)" -ForegroundColor 'White'; break}
	'infos' {Write-Host '   ?    Help params found, show script help' -ForegroundColor 'Blue'; break}
	'start' {Write-Host '   !    Start params found, start the execution of the actual script!' -ForegroundColor 'Green'}
}


Write-Host -Object "[  -  ] Reached the end of the template-runmodes-switch.ps1 script file  .....  " -ForegroundColor 'DarkGray'

