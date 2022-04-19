#Requires -Version 7.2

param (
	[String] $CommandMessage,
	[String] $MpvPipeName = 'ipc_mpv'
)

if ([String]::IsNullOrEmpty($CommandMessage)) {
	Write-Host '[mp.ipc] Usage: mp.ipc.ps1 [-CommandMessage] <mpv IPC Command Message> [[-MpvPipeName] <mpv IPC Pipe Name>]'
	exit 0
}
if ($null -eq ([System.IO.Directory]::GetFiles('\\.\\pipe\\') | Where-Object {$_ -match $MpvPipeName})) {
	Write-Host '[mp.ipc] Error: Named pipe not found, make sure that an mpv instance with IPC enabled is running!'
	exit 1
}

#### Processing of the Command Message
# Remove all line breaks in the command message
$RelayMessage = $CommandMessage -replace "`n|`r"
# According to https://github.com/mpv-player/mpv/blob/master/DOCS/man/ipc.rst, every message must be terminated with \n
$RelayMessage = [String]::Concat($RelayMessage.Trim(), "`n")

if ($RelayMessage.StartsWith('{')) {
	$ExpectReply = $true
} else {
	$ExpectReply = $false
}

#### Init()
$PipeDirectiOpt   = [System.IO.Pipes.PipeDirection]::InOut
$PipeOptionsOpt   = [System.IO.Pipes.PipeOptions]::Asynchronous
$PipeImpersonlOpt = [System.Security.Principal.TokenImpersonationLevel]::Impersonation

$PipeClient = [System.IO.Pipes.NamedPipeClientStream]::new('.', $MpvPipeName, $PipeDirectiOpt, $PipeOptionsOpt, $PipeImpersonlOpt)
$PipeReader = [System.IO.StreamReader]::new($PipeClient)
$PipeWriter = [System.IO.StreamWriter]::new($PipeClient)

#### Main()
try {
	$PipeClient.Connect()

	$PipeWriter.AutoFlush = $true

	$PipeWriter.WriteLine($RelayMessage)

	if ($ExpectReply) {
		$IncomingData = $PipeReader.ReadLine()
		Write-Output $IncomingData
	}
}
catch {
	Write-Host '[mp.ipc] Unhandled exception occured!' -ForegroundColor Red
	Write-Host $_ -ForegroundColor DarkRed
	Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
}
finally {
	$PipeWriter.Dispose()
	$PipeReader.Dispose()
	$PipeClient.Dispose()
}

