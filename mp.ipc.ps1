#Requires -Version 7.2

param (
	[switch] $Play,
	[switch] $Pause,
	[switch] $Stop,
	[switch] $Minimize,
	[switch] $Maximize,
	[switch] $Restore,
	[string] $LoadFile,
	[switch] $Quit,
	[string] $RawCommandMessage,
	[string] $MpvPipeName = 'ipc_mpv'
)

$ccRR = $PSStyle.Reset
$ccHC = $PSStyle.Foreground.Blue
$ccHI = $PSStyle.Foreground.Cyan
$ccAC = $PSStyle.Foreground.Green
$ccYY = $PSStyle.Foreground.Yellow
$ccIB = $PSStyle.Foreground.BrightBlue
$ccMS = $PSStyle.Foreground.BrightWhite
$ccWR = $PSStyle.Foreground.BrightYellow

$Info = @"
${ccAC}mp.ipc${ccRR} 0.1

${ccYY}USAGE:${ccRR}
    mp.ipc.ps1 <COMMANDS> | [-LoadFile] <File> | [-RawCommandMessage] <mpv IPC command> [[-MpvPipeName] <mpv IPC server named pipe>]

${ccYY}COMMANDS:${ccRR}
    ${ccAC}-Play                 ${ccRR}Starts or resumes playback of the currently loaded playlist entry
    ${ccAC}-Pause                ${ccRR}Pauses playback and sets mpv into the pause state
    ${ccAC}-Stop                 ${ccRR}Sends the stop command to the mpv IPC instance
    ${ccAC}-Minimize             ${ccRR}Minimizes the output window of mpv (if a window is visible)
    ${ccAC}-Maximize             ${ccRR}Maximizes the output window of mpv (if a window is visible)
    ${ccAC}-Restore              ${ccRR}Restores the output window to the initial size
    ${ccAC}-LoadFile             ${ccRR}Point to a file that gets opened by mpv
    ${ccAC}-Quit                 ${ccRR}Sends the quit command to the mpv IPC instance
    ${ccAC}-RawCommandMessage    ${ccRR}Pack a command message to mpv in a single string and send it
    ${ccAC}-MpvPipeName          ${ccRR}Specify the named pipe of a mpv instance this script is trying to connect to
"@

if ($null -eq ([System.IO.Directory]::GetFiles('\\.\\pipe\\') | Where-Object {$_ -match $MpvPipeName})) {
	$ErrorMsg = '[mp.ipc] Error: Named pipe not found, make sure that an mpv IPC instance with a matching pipe is running!'
	Write-Host $ErrorMsg -ForegroundColor DarkRed
	exit 255
}
if ($PSBoundParameters.Count -eq 0) {
	Write-Host $Info
	exit 0
}

$RelayMessage = $RawCommandMessage.Trim()
$RelayMessage = $RelayMessage -replace "`n|`r"
$RelayMessage = [String]::Concat($RelayMessage, "`n")
$AwaitMessage = ($RelayMessage.StartsWith('{')) ? $true : $false

if ($RawCommandMessage) {
	if ($AwaitMessage) {
		$CommandObjc = ConvertFrom-Json $RelayMessage
		$CommandStr = ''
		foreach ($e in $CommandObjc.command) {$CommandStr += '"' + $e + '" '}
	}
}

$Strs = @{
	Prfx = "${ccRR}[mp.ipc]${ccMS}"
	Resp = "Response from mpv IPC server instance at named pipe"
	Stat = "received: ${ccHI}Status${ccRR} ->"
	Subm = "$($PSStyle.Foreground.BrightBlack)Returned message for command:${ccRR}"
}
$Text = @{
	Success = "$($Strs.Prfx) $($Strs.Resp) '${ccHC}" + $MpvPipeName + "${ccMS}' $($Strs.Stat) ${ccAC}Successful${ccMS}!"
	Failure = "$($Strs.Prfx) $($Strs.Resp) '${ccHC}" + $MpvPipeName + "${ccMS}' $($Strs.Stat) ${ccWR}Failure${ccMS}!"
	Respmsg = "$($Strs.Prfx) $($Strs.Subm) $CommandStr$($PSStyle.Foreground.BrightBlack)is..."
}

$PipeDirectiOpt = [System.IO.Pipes.PipeDirection]::InOut
$PipeOptionsOpt = [System.IO.Pipes.PipeOptions]::Asynchronous
$PipeImpersnOpt = [System.Security.Principal.TokenImpersonationLevel]::Impersonation
$PipeClient = [System.IO.Pipes.NamedPipeClientStream]::new('.', $MpvPipeName, $PipeDirectiOpt, $PipeOptionsOpt, $PipeImpersnOpt)
$PipeReader = [System.IO.StreamReader]::new($PipeClient)
$PipeWriter = [System.IO.StreamWriter]::new($PipeClient)

try {
	$PipeClient.Connect()
	$PipeWriter.AutoFlush = $true

	$PipeWriter.WriteLine($RelayMessage)

	if ($AwaitMessage) {
		$IncomingData = $PipeReader.ReadLine()
		$ResponseObjc = ConvertFrom-Json $IncomingData
		if ($ResponseObjc.error -eq 'success') {
			Write-Host $Text.Success
			Write-Host $Text.Respmsg
			Write-Host "$($Strs.Prfx) -".PadRight(($Text.Success.Length - 29), '-')
			Write-Host "[mp.ipc] $($ResponseObjc.data)"
			Write-Host "$($Strs.Prfx) -".PadRight(($Text.Success.Length - 29), '-')
		}
		else {
			Write-Host $Text.Failure
			Write-Host $Text.Respmsg
			Write-Host "$($Strs.Prfx) -".PadRight(($Text.Success.Length - 32), '-')
			Write-Host "[mp.ipc] $($ResponseObjc.error)"
			Write-Host "$($Strs.Prfx) -".PadRight(($Text.Success.Length - 32), '-')
		}
	}
}
catch {
	Write-Host '[mp.ipc] Error: Unhandled exception occured!' -ForegroundColor Red
	Write-Host $_ -ForegroundColor DarkRed
	Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
}
finally {
	$PipeWriter.Dispose()
	$PipeReader.Dispose()
	$PipeClient.Dispose()
}

