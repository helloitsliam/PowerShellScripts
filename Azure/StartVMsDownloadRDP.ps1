
## Start DC VM
$serverName = "{Server Name}"
$cloudService = "{Type Cloud Service Name}"
Start-AzureVM -ServiceName $cloudService -Name $serverName

## Download RDP file within DC Cloud Service
Get-AzureVM -ServiceName $cloudService | foreach { 
	$rdpfile = '{Output Path}' + $_.Name + '.rdp'
	Get-AzureRemoteDesktopFile -ServiceName $cloudService -Name $_.Name -LocalPath $rdpfile
}