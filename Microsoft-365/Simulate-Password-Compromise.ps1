####################################################################################################################################
##                                                                                                                                ##
##  Authenticates with Microsoft Graph as an admin.                                                                               ##
##  Changes the password of a specified user.                                                                                     ##
##  Authenticates as the compromised user using the new password.                                                                 ##
##  Performs actions as the compromised user, such as accessing their inbox.                                                      ##
##  Disconnects from Microsoft Graph.                                                                                             ##
##  Authenticates as an admin again and resets the compromised user's password, forcing a password change on their next sign-in.  ##
##                                                                                                                                ##
####################################################################################################################################

# Authenticate with Microsoft Graph
Connect-MgGraph

# Define the user you want to simulate the password compromise for
$userId = "user@example.com" # Replace this with the user's email address

# Change the user's password
$compromisedPassword = "CompromisedPassword123!"
Set-MgUserPassword -UserId $userId -NewPassword $compromisedPassword -ForceChangePasswordNextSignIn $false
Write-Host "User password changed: $userId"

# Authenticate as the compromised user
$credentials = New-Object System.Management.Automation.PSCredential ($userId, (ConvertTo-SecureString $compromisedPassword -AsPlainText -Force))
Connect-MgGraph -Credential $credentials

# Perform actions as the compromised user
$loggedUser = Get-MgMe
$loggedUserMailboxes = Get-MgUserMailFolderMessage -UserId $loggedUser.Id -MailFolderId 'inbox'
Write-Host "Accessed $($loggedUserMailboxes.Count) emails from $($loggedUser.DisplayName)'s inbox."

# Disconnect from Microsoft Graph
Disconnect-MgGraph

# Authenticate as an admin again and reset the user's password
Connect-MgGraph
$newPassword = "NewSecurePassword123!"
Set-MgUserPassword -UserId $userId -NewPassword $newPassword -ForceChangePasswordNextSignIn $true
Write-Host "User password reset: $userId"

