param([string]$DocumentPath,[string]$PdfPath)
$ErrorActionPreference = 'Stop'
$courseWord = $null
$courseDoc = $null
try {
    $courseWord = New-Object -ComObject Word.Application
    $courseWord.Visible = $false
    $courseWord.DisplayAlerts = 0
    $courseDoc = $courseWord.Documents.Open($DocumentPath, $false, $true)
    $courseDoc.Repaginate()
    $coursePages = $courseDoc.ComputeStatistics(2)
    $courseDoc.ExportAsFixedFormat($PdfPath,17)
    Write-Output "Pages: $coursePages"
} finally {
    if ($null -ne $courseDoc) { $courseDoc.Close(0); [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($courseDoc) }
    if ($null -ne $courseWord) { $courseWord.Quit(); [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($courseWord) }
}
