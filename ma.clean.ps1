Write-Host -ForegroundColor White '[MNTNC] : Simple Cleaning Script -> Now Running...'
$ErrActPreferenceSaved = $ErrorActionPreference
$ConfrmPreferenceSaved = $ConfirmPreference
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Continue
$ConfirmPreference = [System.Management.Automation.ConfirmImpact]::None

Write-Host -ForegroundColor DarkGray '[01/03] : Cleaning System Temp directory in %Windir%'
Convert-Path -LiteralPath "$Env:Windir\Temp" | Push-Location
$ItemA = Get-ChildItem -Path "*" -Force
Remove-Item -Path "*" -Recurse -Force
Write-Host -ForegroundColor DarkGray "   >    : $($ItemA.Count) item(s) removed..."
Pop-Location

Write-Host -ForegroundColor DarkGray '[02/03] : Cleaning User Temp directory in %LocalAppData%'
Convert-Path -LiteralPath "$Env:LocalAppData\Temp" | Push-Location
$ItemB = Get-ChildItem -Path "*" -Force
Remove-Item -Path "*" -Recurse -Force
Write-Host -ForegroundColor DarkGray "   >    : $($ItemB.Count) item(s) removed..."
Pop-Location

Write-Host -ForegroundColor DarkGray '[03/03] : Cleaning empty "tmp" content in %Windir%\System32\config\systemprofile\AppData\Local'
Convert-Path -LiteralPath "$Env:Windir\System32\config\systemprofile\AppData\Local\" | Push-Location
$ItemC = Get-ChildItem -Path "*.tmp" -Force -File
$ItemD = Get-ChildItem -Path "tw-*.tmp" -Force
$ItemC | Remove-Item -Force
$ItemD | Remove-Item -Force
Write-Host -ForegroundColor DarkGray "   >    : $($ItemC.Count + $ItemD.Count) item(s) removed..."
Pop-Location

Write-Host -ForegroundColor White '[MNTNC] : Simple Cleaning Script -> Cleaned all the entries!'
Write-Host -ForegroundColor DarkGray "   $    : $($ItemA.Count + $ItemB.Count + $ItemC.Count + $ItemD.Count) item(s) removed in total!"
$ErrorActionPreference = $ErrActPreferenceSaved
$ConfirmPreference = $ConfrmPreferenceSaved
Remove-Variable -Name ErrActPreferenceSaved,ConfrmPreferenceSaved,ItemA,ItemB,ItemC,ItemD
Write-Host -ForegroundColor White "[MNTNC] : Simple Cleaning Script $($PSStyle.Italic)$($PSStyle.Foreground.Green)DONE$($PSStyle.Reset)"

