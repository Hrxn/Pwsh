param
(
	[string] $Command,
	[switch] $Help
)

enum RunModeType {Norun; Infos; Start}

$InfoCmd = 'help', 'info', '--help', '--info', '?'

switch ($Command) {
	{$_ -eq 'start' -and (-not ($script:args.Count -gt 0))} {$RunMode = [RunModeType]::Start}
	{$_ -in $InfoCmd -or $Help}                             {$RunMode = [RunModeType]::Infos}
	default                                                 {$RunMode = [RunModeType]::Norun}
}


Write-Host -Object "[  -  ] The beginning, of this template-runmodes-switch.ps1 script file  .....  " -ForegroundColor 'DarkGray'

# Example 1: switch statement using implicit string type

switch ($RunMode) {
	Norun {Write-Host "   -    Incorrect parameter usage! | Display Info and Usage Message | $($PSStyle.Foreground.BrightCyan)command -> $command $($PSStyle.Reset)| $($PSStyle.Foreground.BrightCyan)args -> $args $($PSStyle.Reset)" -ForegroundColor 'White'; break}
	Infos {Write-Host '   ?    Help params found, show script help' -ForegroundColor 'Blue'; break}
	Start {Write-Host '   !    Start params found, start the execution of the actual script!' -ForegroundColor 'Green'}
}

# Example 2: switch statement using strongly typed enums (parentheses are needed here) (for a single-valued expression as the test: continue = break)

switch ($RunMode) {
	([RunModeType]::Norun) {Write-Host "   -    Incorrect parameter usage! | Display Info and Usage Message | $($PSStyle.Foreground.BrightCyan)command -> $command $($PSStyle.Reset)| $($PSStyle.Foreground.BrightCyan)args -> $args $($PSStyle.Reset)" -ForegroundColor 'White'; continue}
	([RunModeType]::Infos) {Write-Host '   ?    Help params found, show script help' -ForegroundColor 'Blue'; continue}
	([RunModeType]::Start) {Write-Host '   !    Start params found, start the execution of the actual script!' -ForegroundColor 'Green'; continue}
}

# Example 3: switch statement using explicit verbatim strings

switch ($RunMode) {
	'Norun' {Write-Host "   -    Incorrect parameter usage! | Display Info and Usage Message | $($PSStyle.Foreground.BrightCyan)command -> $command $($PSStyle.Reset)| $($PSStyle.Foreground.BrightCyan)args -> $args $($PSStyle.Reset)" -ForegroundColor 'White'; continue}
	'Infos' {Write-Host '   ?    Help params found, show script help' -ForegroundColor 'Blue'; continue}
	'Start' {Write-Host '   !    Start params found, start the execution of the actual script!' -ForegroundColor 'Green'; continue}
}


Write-Host -Object "[  -  ] Reached the end of the template-runmodes-switch.ps1 script file  .....  " -ForegroundColor 'DarkGray'
