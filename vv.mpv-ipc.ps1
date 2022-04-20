#Requires -Version 7.2

param (
	[string] $IPCPipeName = 'ipc_mpv',
	[switch] $ShowWindow,
	[switch] $Minimized
)

$SavedConTitle = [Console]::Title
[Console]::Title = "[mp.ipc] mpv IPC server instance (named pipe: $IPCPipeName) is currently running..."

$FQPN = "\\.\pipe\$IPCPipeName"

if ($ShowWindow) {
	if ($Minimized) {
		mpv --input-ipc-server=$FQPN --idle=yes --pause=yes --force-window=yes --window-minimized=yes
	}
	else {
		mpv --input-ipc-server=$FQPN --idle=yes --pause=yes --force-window=yes
	}
}
else {
	mpv --input-ipc-server=$FQPN --idle=yes --pause=yes
}

[Console]::WriteLine("[mp.ipc] mpv IPC server instance (named pipe: $IPCPipeName) just quit...")
[Console]::Title = $SavedConTitle
