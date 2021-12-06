Write-Host -ForegroundColor White -Object '[MNTNC] : Simple Cleaning Script -> Now Running...'

function Print-Error {
	$ErrString = "   >    : Could not delete some files in '$(Get-Location)', they might be in use by another process."
	Write-Host -ForegroundColor DarkYellow -Object $ErrString
}

$ErrActPreferenceSaved = $ErrorActionPreference
$ConfrmPreferenceSaved = $ConfirmPreference
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$ConfirmPreference = [System.Management.Automation.ConfirmImpact]::None


Write-Host -ForegroundColor DarkGray -Object '[01/03] : Cleaning System Temp directory in %Windir%'
Convert-Path -LiteralPath "$Env:Windir\Temp" | Push-Location
$ItemA = Get-ChildItem -Path "*" -Force
try {
	Remove-Item -Path "*" -Recurse -Force
	Write-Host -ForegroundColor DarkGray -Object "   >    : $($ItemA.Count) item(s) removed..."
}
catch {
	$ItemA = $null
	Print-Error
}
Pop-Location

Write-Host -ForegroundColor DarkGray -Object "[02/03] : Cleaning User's Temp directory in %LocalAppData%"
Convert-Path -LiteralPath "$Env:LocalAppData\Temp" | Push-Location
$ItemB = Get-ChildItem -Path "*" -Force
try {
	Remove-Item -Path "*" -Recurse -Force
	Write-Host -ForegroundColor DarkGray -Object "   >    : $($ItemB.Count) item(s) removed..."
}
catch {
	$ItemB = $null
	Print-Error
}
Pop-Location

$InfString = '[03/03] : Cleaning "tmp" content in %Windir%\System32\config\systemprofile\AppData\Local'
Write-Host -ForegroundColor DarkGray -Object $InfString
Convert-Path -LiteralPath "$Env:Windir\System32\config\systemprofile\AppData\Local\" | Push-Location
$ItemC = Get-ChildItem -Path "*.tmp" -Force -File
$ItemD = Get-ChildItem -Path "tw-*.tmp" -Force
try {
	$ItemC | Remove-Item -Force
	$ItemD | Remove-Item -Force
	Write-Host -ForegroundColor DarkGray -Object "   >    : $($ItemC.Count + $ItemD.Count) item(s) removed..."
}
catch {
	$ItemC, $ItemD = $null
	Print-Error
}
Pop-Location

$InfString = '[MNTNC] : Simple Cleaning Script -> Cleaned all the entries!'
Write-Host -ForegroundColor White -Object $InfString
$InfString = "   =    : $($ItemA.Count + $ItemB.Count + $ItemC.Count + $ItemD.Count) item(s) removed in total!"
Write-Host -ForegroundColor Cyan -Object $InfString
$InfString = "[MNTNC] : Simple Cleaning Script $($PSStyle.Underline)$($PSStyle.Foreground.Green)DONE$($PSStyle.Reset)"
Write-Host -ForegroundColor White -Object $InfString
$ErrorActionPreference = $ErrActPreferenceSaved
$ConfirmPreference = $ConfrmPreferenceSaved
Remove-Variable -Name ErrActPreferenceSaved, ConfrmPreferenceSaved, InfString, ItemA, ItemB, ItemC, ItemD

