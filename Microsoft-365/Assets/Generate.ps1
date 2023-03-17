# Read the JSON configuration
$configPath = "/Users/liamcleary/Dropbox/Code/GitHub/PowerShellScripts/Microsoft-365/Assets/config.json"
$configJson = Get-Content $configPath | ConvertFrom-Json

# Extract the configuration properties
$numberOfFiles = $configJson.Configuration.Number
$fileExtensions = $configJson.Configuration.FileExtensions

# Set the output folder
$outputFolder = "/Users/liamcleary/Dropbox/Code/GitHub/PowerShellScripts/Microsoft-365/GeneratedFiles"
if (-not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# Function to generate a random document
function GenerateRandomDocument {
    param (
        $fileExtensions,
        $outputFolder
    )

    $fileExtensionObj = $fileExtensions | Get-Random
    $fileExtension = $fileExtensionObj.Extension
    $contentArray = $fileExtensionObj.Content
    $content = $contentArray | Get-Random

    $fileName = [guid]::NewGuid().ToString() + "." + $fileExtension
    $filePath = Join-Path $outputFolder $fileName

    switch ($fileExtension) {
        'doc' {
            $word = New-Object -TypeName Word.Application
            $word.Visible = $false
            $doc = $word.Documents.Add()
            $selection = $word.Selection
            $selection.TypeText($content)
            $doc.SaveAs([ref]$filePath, [ref]0)  # wdFormatDocument
            $doc.Close([ref]$false)
            $word.Quit()
        }
        'docx' {
            $word = New-Object -TypeName Word.Application
            $word.Visible = $false
            $doc = $word.Documents.Add()
            $selection = $word.Selection
            $selection.TypeText($content)
            $doc.SaveAs([ref]$filePath, [ref]16)  # wdFormatDocumentDefault
            $doc.Close([ref]$false)
            $word.Quit()
        }
        'xls' {
            $excel = New-Object -TypeName Excel.Application
            $excel.Visible = $false
            $workbook = $excel.Workbooks.Add()
            $worksheet = $workbook.Worksheets.Item(1)
            $data = $content -split "`r`n" | ForEach-Object { $_ -split "`t" }
            $range = $worksheet.Range("A1").Resize($data.Count, $data[0].Count)
            $range.Value2 = $data
            $workbook.SaveAs($filePath, 56)  # xlExcel8
            $workbook.Close($false)
            $excel.Quit()
        }
        'xlsx' {
            $excel = New-Object -TypeName Excel.Application
            $excel.Visible = $false
            $workbook = $excel.Workbooks.Add()
            $worksheet = $workbook.Worksheets.Item(1)
            $data = $content -split "`r`n" | ForEach-Object { $_ -split "`t" }
            $range = $worksheet.Range("A1").Resize($data.Count, $data[0].Count)
            $range.Value2 = $data
            $workbook.SaveAs($filePath, 51)  # xlOpenXMLWorkbook
            $workbook.Close($false)
            $excel.Quit()
        }
        'ppt' {
            $powerpoint = New-Object -TypeName PowerPoint.Application
            $powerpoint.Visible = [Microsoft.Office.Core.MsoTriState]::msoTrue
            $presentation = $powerpoint.Presentations.Add()
            $slide = $presentation.Slides.Add(1, [Microsoft.Office.Interop.PowerPoint.PpSlideLayout]::ppLayoutText)
            $slide.Shapes.Title.TextFrame.TextRange.Text = $content
            $presentation.SaveAs($filePath, [Microsoft.Office.Interop.PowerPoint.PpSaveAsFileType]::ppSaveAsPresentation)
            $presentation.Close()
            $powerpoint.Quit()
        }
        'pptx' {
            $powerpoint = New-Object -TypeName PowerPoint.Application
            $powerpoint.Visible = [Microsoft.Office.Core.MsoTriState]::msoTrue
            $presentation = $powerpoint.Presentations.Add()
            $slide = $presentation.Slides.Add(1, [Microsoft.Office.Interop.PowerPoint.PpSlideLayout]::ppLayoutText)
            $slide.Shapes.Title.TextFrame.TextRange.Text = $content
            $presentation.SaveAs($filePath, [Microsoft.Office.Interop.PowerPoint.PpSaveAsFileType]::ppSaveAsOpenXMLPresentation)
            $presentation.Close()
            $powerpoint.Quit()
        }
        'txt' {
            Set-Content -Path $filePath -Value $content
        }
        'csv' {
            Set-Content -Path $filePath -Value $content
        }
        'xml' {
            Set-Content -Path $filePath -Value $content
        }
        'pdf' {
            Write-Warning "File extension '$fileExtension' is not supported with COM objects in this script."
            return
        }
        'rtf' {
            Write-Warning "File extension '$fileExtension' is not supported with COM objects in this script."
            return
        }
        'odt' {
            Write-Warning "File extension '$fileExtension' is not supported with COM objects in this script."
            return
        }
        default {
            Write-Warning "File extension '$fileExtension' is not supported in this script."
            return
        }
    }

    Write-Host "Generated file: $filePath"
}
    


# Generate the specified number of documents
#1..$numberOfFiles | 

1..5 | ForEach-Object {
    GenerateRandomDocument -fileExtensions $fileExtensions -outputFolder $outputFolder
}
    

