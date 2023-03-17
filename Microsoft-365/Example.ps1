############################################################################################################################################
##                                                                                                                                        ##
##  Authenticates with Microsoft Graph and Microsoft 365 Defender.                                                                        ##
##  Retrieves security alerts.                                                                                                            ##
##  For each alert, it performs actions depending on the alert's severity, such as blocking high-risk users or resetting user passwords.  ##
##  Retrieves a list of devices.                                                                                                          ##
##  For each device, it checks if the device is running an outdated operating system and blocks it if needed.                             ##
##  Disconnects from Microsoft Graph and Microsoft 365 Defender.                                                                          ##
##                                                                                                                                        ##
############################################################################################################################################

Install-Module -Name Microsoft.Graph -Scope CurrentUser
Install-Module -Name Microsoft365Defender -Scope CurrentUser

# Authenticate with Microsoft Graph and Microsoft 365 Defender
Connect-MgGraph
Connect-Microsoft365Defender

# Get a list of security alerts
$alerts = Get-MgSecurityAlert -Filter "createdDateTime gt 2023-03-01T00:00:00Z"

# Perform an action for each security alert
foreach ($alert in $alerts) {
    # Print the alert's details
    Write-Host "ID: $($alert.Id)"
    Write-Host "Title: $($alert.Title)"
    Write-Host "Status: $($alert.Status)"
    Write-Host "Severity: $($alert.Severity)"
    Write-Host "Created at: $($alert.CreatedDateTime)"
    Write-Host "-----------------------------"

    # Take action based on the alert's severity
    switch ($alert.Severity) {
        'High' {
            # Get users with high-risk sign-ins
            $riskyUsers = Get-MgIdentityRiskyUser -Filter "riskLevel eq 'high'"
            
            # Block high-risk users
            foreach ($user in $riskyUsers) {
                Set-MgUser -UserId $user.Id -AccountEnabled $false
                Write-Host "Blocked high-risk user: $($user.DisplayName)"
            }
        }

        'Medium' {
            # Reset user's password
            $userId = $alert.UserId
            $newPassword = "NewTemporaryPassword123!"
            Set-MgUserPassword -UserId $userId -NewPassword $newPassword -ForceChangePasswordNextSignIn $true
            Write-Host "Reset password for user: $userId"
        }
    }
}

# Get a list of all devices
$devices = Get-MgDevice

# Perform an action for each device
foreach ($device in $devices) {
    # Print the device's details
    Write-Host "ID: $($device.Id)"
    Write-Host "Device Name: $($device.DeviceName)"
    Write-Host "Operating System: $($device.OperatingSystem)"
    Write-Host "-----------------------------"

    # Check if the device is running an outdated operating system
    if ($device.OperatingSystem -eq "Windows" -and $device.OsVersion -lt "10.0") {
        # Block the outdated device
        Set-MgDevice -DeviceId $device.Id -IsBlocked $true
        Write-Host "Blocked outdated device: $($device.DeviceName)"
    }
}

# Disconnect from Microsoft Graph and Microsoft 365 Defender
Disconnect-MgGraph
Disconnect-Microsoft365Defender
