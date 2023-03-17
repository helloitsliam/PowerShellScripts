# Authenticate with Microsoft Graph
Connect-MgGraph

# Get Microsoft 365 Defender alerts
$alerts = Get-MgSecurityAlert -Filter "vendorInformation/provider eq 'Microsoft 365 Defender'" | Sort-Object -Property ActivityGroupStates.CreatedDateTime

# Display alerts in a timeline format
Write-Host "Microsoft 365 Defender Alerts Timeline:"
foreach ($alert in $alerts) {
    Write-Host "--------------------------"
    Write-Host "Timestamp: $($alert.CreatedDateTime)"
    Write-Host "Alert ID: $($alert.Id)"
    Write-Host "Title: $($alert.Title)"
    Write-Host "Description: $($alert.Description)"
    Write-Host "Status: $($alert.Status)"
    Write-Host "Severity: $($alert.Severity)"
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph
