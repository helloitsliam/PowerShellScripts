##############################################################################
##                                                                          ##
##  Authenticates with Microsoft Graph.                                     ##
##  Creates a SharePoint site and document library.                         ##
##  Generates and uploads a large number of files to the document library.  ##
##  Accesses each file to simulate a user attempting to read them.          ##
##  Removes the SharePoint site and disconnects from Microsoft Graph.       ##
##                                                                          ##
##############################################################################

# Authenticate with Microsoft Graph
Connect-MgGraph

# Set the number of files to simulate access
$numberOfFiles = 1000

# Create a SharePoint site and document library
$site = New-MgSite -DisplayName "Simulated Data Breach Site"
$library = New-MgList -SiteId $site.Id -DisplayName "Simulated Data Breach Library" -ListTemplate "documentLibrary"

# Create and upload files to the document library
for ($i = 1; $i -le $numberOfFiles; $i++) {
    # Create a temporary file
    $tempFile = New-TemporaryFile
    Set-Content -Path $tempFile.FullName -Value "Simulated data for file $i"
    
    # Upload the file to the document library
    $fileName = "File_$i.txt"
    $fileUrl = "/sites/$($site.SiteCollection.HostName)/$($site.WebUrl)/$library.DisplayName/$fileName"
    Add-MgDriveItemContent -DriveId $site.DriveId -Path $fileUrl -SourceFilePath $tempFile.FullName -ContentType "text/plain"
    
    # Access the file (simulate file read)
    $file = Get-MgDriveItem -DriveId $site.DriveId -ItemId $fileUrl
    $fileContent = Get-MgDriveItemContent -DriveId $site.DriveId -ItemId $fileUrl
    
    Write-Host "Accessed file: $fileName"
}

# Cleanup: Remove SharePoint site
Remove-MgSite -SiteId $site.Id -Force

# Disconnect from Microsoft Graph
Disconnect-MgGraph
