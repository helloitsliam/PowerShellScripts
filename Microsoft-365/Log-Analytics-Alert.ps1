##############################################################################
##                                                                          ##
##  Imports the required Azure modules and connects to your Azure account.  ##
##  Defines your Log Analytics Workspace information.                       ##
##  Retrieves your Log Analytics Workspace details.                         ##
##  Defines a fake security log.                                            ##
##  Converts the log data to Log Analytics Data Collector API format.       ##
##  Generates the request headers for the Log Analytics Data Collector API. ##
##  Sends the fake security log to your Azure Log Analytics Workspace.      ##
##                                                                          ##
##############################################################################

# Import required modules
Install-Module -Name Az -Scope CurrentUser -Force
Install-Module -Name Az.OperationalInsights -Scope CurrentUser -Force

# Connect to your Azure account
Connect-AzAccount

# Define the Log Analytics Workspace information
$resourceGroupName = "YourResourceGroupName" # Replace with your resource group name
$workspaceName = "YourWorkspaceName" # Replace with your Log Analytics workspace name

# Get the Log Analytics Workspace
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroupName -Name $workspaceName
$customerId = $workspace.CustomerId.Guid
$sharedKey = (Get-AzOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $resourceGroupName -Name $workspaceName).PrimarySharedKey

# Define the fake security log
$logType = "FakeSecurityLog"
$timestamp = (Get-Date).ToUniversalTime().ToString("o")
$fakeSecurityLog = @"
[
  {
    "TimeStamp": "$timestamp",
    "AlertName": "FakeSecurityAlert",
    "AlertDescription": "This is a fake security alert for simulation purposes.",
    "Severity": "High"
  }
]
"@

# Convert the log data to Log Analytics Data Collector API format
$bytes = [System.Text.Encoding]::UTF8.GetBytes($fakeSecurityLog)
$encodedLog = [System.Convert]::ToBase64String($bytes)

# Generate the request headers for the Log Analytics Data Collector API
$date = (Get-Date).ToUniversalTime().ToString("R")
$method = "POST"
$contentType = "application/json"
$resource = "/api/logs"
$stringToSign = "$method`n$bytes.Length`n$contentType`n$date`n$resource"
$bytesToSign = [System.Text.Encoding]::UTF8.GetBytes($stringToSign)
$hmacsha256 = New-Object System.Security.Cryptography.HMACSHA256
$hmacsha256.Key = [System.Convert]::FromBase64String($sharedKey)
$signature = $hmacsha256.ComputeHash($bytesToSign)
$signature = [System.Convert]::ToBase64String($signature)
$auth = "SharedKey $($customerId):$signature"
$headers = @{
    "Authorization" = $auth
    "Log-Type" = $logType
    "x-ms-date" = $date
    "time-generated-field" = "TimeStamp"
}

# Send the fake security log to Log Analytics
$uri = "https://$($workspace.PrimaryDataLakeStoreUri)/api/logs?api-version=2016-04-01"
$response = Invoke-WebRequest -Uri $uri -Method $method -Body $encodedLog -ContentType $contentType -Headers $headers
Write-Host "Fake security log sent to Azure Log Analytics."


######################################################
##                                                  ##
## FakeSecurityLog_CL | where Severity_s == "High"  ##
##                                                  ##
######################################################

# Go to the Azure Sentinel portal in the Azure Portal.
# Click on "Analytics" in the left-hand menu.
# Click on "Create" to create a new rule.
# Fill in the required information for the rule, such as the rule name and description.
# In the "Set rule logic" section, provide a custom query based on the fake security logs. For example:
# FakeSecurityLog_CL
# | where Severity_s == "High"
# Configure the rule's settings, such as the alert severity, tactics, and the rule's frequency and period.
# Save the rule.

