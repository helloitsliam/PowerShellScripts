function Get-AccessTokenAzureADCached {
    [CmdletBinding()]
    param()

    try {
        Write-Verbose "Trying to acquire Azure AD access token from a local cache..."
        $token = [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens['AccessToken'].AccessToken
        Write-Verbose "Got it."
        return $token
    } catch {
        Write-Verbose "Nope. That didn't work."
        return ""
    }
}


$credential = New-Object System.Management.Automation.PSCredential("", $token)
Connect-MgGraph -Credential $credential



$accessToken = "YourAccessTokenHere"

# Set the Authorization header with the bearer token
$header = @{
    'Authorization' = "Bearer $token"
}
Connect-MgGraph -Headers $header

# Once connected, you can run cmdlets to manage and monitor your Microsoft 365 environment.
