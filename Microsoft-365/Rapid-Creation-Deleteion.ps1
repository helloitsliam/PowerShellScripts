####
##  
##  
##  
###

# Authenticate with Microsoft Graph
Connect-MgGraph

# Define the number of users to create and delete
$numberOfUsers = 10

# Create, list, and delete users in a loop
for ($i = 1; $i -le $numberOfUsers; $i++) {
    # Create a new user
    $userDisplayName = "SimulatedUser_$i"
    $userMailNickname = "simulateduser$i"
    $userPassword = "TempPassword123!"
    $securePassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
    $newUser = @{
        accountEnabled = $true
        displayName = $userDisplayName
        mailNickname = $userMailNickname
        userPrincipalName = "$userMailNickname@example.onmicrosoft.com"
        passwordProfile = @{
            forceChangePasswordNextSignIn = $true
            password = $userPassword
        }
    } | ConvertTo-Json
    $createdUser = New-MgUser -BodyParameter $newUser
    Write-Host "Created user: $($createdUser.DisplayName)"

    # List all users
    $users = Get-MgUser
    Write-Host "Total users: $($users.Count)"

    # Delete the created user
    Remove-MgUser -UserId $createdUser.Id -Force
    Write-Host "Deleted user: $($createdUser.DisplayName)"
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph
