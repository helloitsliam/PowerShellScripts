Get-AzureVM | Where-Object {$_.Status -like "Ready*"} | ForEach-Object { Stop-AzureVM -ServiceName $_.ServiceName -Name $_.Name -Force }