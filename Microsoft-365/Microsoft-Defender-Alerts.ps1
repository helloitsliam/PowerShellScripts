# Authenticate with Microsoft Graph
Connect-MgGraph

# Get Microsoft 365 Defender alerts
$alerts = Get-MgSecurityAlert -Filter "vendorInformation/provider eq 'Microsoft 365 Defender'"
foreach ($alert in $alerts) {
    Write-Host "Alert ID: $($alert.Id)"
    Write-Host "Title: $($alert.Title)"
    Write-Host "Description: $($alert.Description)"
    Write-Host "Status: $($alert.Status)"
    Write-Host "Severity: $($alert.Severity)"
    Write-Host "--------------------------"
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph
