####################################################################################################################################################
##                                                                                                                                                ##
##  Authenticates to Microsoft Graph using an administrator account.                                                                              ##
##  Retrieves a list of user accounts to spray passwords against, using the Get-MgUser cmdlet.                                                    ##
##  Defines a list of passwords to spray against the user accounts.                                                                               ##
##  Loops through the list of user accounts and passwords, using the Test-MgUserPassword cmdlet to test each password against each user account.  ##
##  If the authentication attempt is successful, takes appropriate action, such as resetting the user's password or disabling the account.        ##
##                                                                                                                                                ##
####################################################################################################################################################

# Authenticate to Microsoft Graph using an administrator account
Connect-MgGraph -Scopes "SecurityEvents.ReadWrite.All"

# Retrieve a list of user accounts to spray passwords against
$users = Get-MgUser -All $true | Where-Object { $_.AccountEnabled }

# Define a list of passwords to spray against the user accounts
$passwords = @("password1", "password2", "password3")

# Loop through the list of user accounts and passwords
foreach ($user in $users) {
    foreach ($password in $passwords) {
        # Test the password against the user account
        $result = Test-MgUserPassword -UserId $user.Id -Password $password

        # If the authentication attempt is successful, take appropriate action
        if ($result) {
            # Reset the user's password or disable the account, for example
            Write-Host "Successful authentication for user $($user.UserPrincipalName) using password '$password'"
        }
    }
}
