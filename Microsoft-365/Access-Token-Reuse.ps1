# Import the required modules
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force
Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force

# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName "you@example.com" -ShowProgress $true

# Save the current token information
$exchangeToken = Get-ExoPSSession | Select-Object -ExpandProperty Token

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false

# Set up the Microsoft Graph context with the saved access token
$graphToken = @{
    Token         = $exchangeToken.access_token
    ExpiresOn     = $exchangeToken.expires_on
    TokenType     = $exchangeToken.token_type
    RefreshToken  = $exchangeToken.refresh_token
    Scope         = $exchangeToken.scope
    ClientId      = $exchangeToken.client_id
    TenantId      = $exchangeToken.tenant_id
    ClientSecret  = $exchangeToken.client_secret
}

Set-MgContext -ContextData $graphToken

# Perform an Exchange Online action using Microsoft.Graph
$mailboxes = Get-MgUser -Filter "mail ne null" -Select "displayName,mail"
$mailboxes.value | Format-Table -AutoSize

# Perform a SharePoint Online action using Microsoft.Graph
$tenantName = "yourtenant" # Replace with your tenant name
$siteUrl = "https://$tenantName.sharepoint.com"

$spSite = Get-MgSite -SiteUrl $siteUrl
Write-Host "SharePoint Site Title: $($spSite.DisplayName)"
