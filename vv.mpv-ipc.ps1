#Requires -Version 7.2

param (
	[string[]] $MpvOptions,
	[string] $IPCPipeName = 'ipc_mpv',
	[switch] $ShowWindow,
	[switch] $Minimized
)

if ($null -eq (Get-Command -Name 'mpv' -ErrorAction Ignore)) {
	Write-Host '[mp.ipc] : Error -> Dependency Error: Missing dependency: mpv' -ForegroundColor DarkRed
	exit 254
}

$DefinedPipeName = "\\.\pipe\$IPCPipeName"

$SavedCnslwTitle = [Console]::Title
[Console]::Title = "[mp.ipc] mpv IPC server instance (pipe name: ""$IPCPipeName"") is currently running..."

if ($ShowWindow) {
	if ($Minimized) {
		$MpvStartCmd = "mpv --input-ipc-server=$DefinedPipeName --idle=yes --pause=yes --force-window=yes --window-minimized=yes"
	}
	else {
		$MpvStartCmd = "mpv --input-ipc-server=$DefinedPipeName --idle=yes --pause=yes --force-window=yes"
	}
}
else {
	$MpvStartCmd = "mpv --input-ipc-server=$DefinedPipeName --idle=yes --pause=yes"
}

if ($MpvOptions) {
	$MpvStartCmd = [String]::Concat($MpvStartCmd, ' ', $MpvOptions)
}

[Console]::WriteLine("[mp.ipc] mpv IPC server instance (pipe name: ""$IPCPipeName"") is now starting...")
[Console]::TreatControlCAsInput = $true

Invoke-Expression -Command $MpvStartCmd

[Console]::Title = $SavedCnslwTitle
[Console]::WriteLine("[mp.ipc] mpv IPC server instance (pipe name: ""$IPCPipeName"") just exited...")
