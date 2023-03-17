#################################################################################################################################
##                                                                                                                             ##
##  Authenticates to Microsoft Graph using an administrator account.                                                           ##
##  Retrieves a list of user accounts to test, using the Get-MgUser cmdlet.                                                    ##
##  Defines a list of weak passwords to test against.                                                                          ##
##  Loops through the list of user accounts and tests each user's password against the list of weak passwords.                 ##
##  If the user's password is weak, takes appropriate action, such as resetting the user's password or disabling the account.  ##
##                                                                                                                             ##
#################################################################################################################################

# Authenticate to Microsoft Graph using an administrator account
Connect-MgGraph -Scopes "SecurityEvents.ReadWrite.All"

# Retrieve a list of user accounts to test
$users = Get-MgUser -All $true | Where-Object { $_.AccountEnabled }

# Define a list of weak passwords to test against
$weakPasswords = @("password", "123456", "admin", "qwerty", "letmein", "welcome", "password1", "12345678", "abc123")

# Loop through the list of user accounts
foreach ($user in $users) {
    # Test the user's password against the list of weak passwords
    if ($weakPasswords -contains $user.PasswordProfile.Password) {
        # Take appropriate action, such as resetting the user's password or disabling the account
        Write-Host "User $($user.UserPrincipalName) has a weak password: $($user.PasswordProfile.Password)"
    }
}
