param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $FlutterArguments
)
$ErrorActionPreference = 'Stop'
$taskRoot = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$taskWorkingPath = $taskRoot
# Windows Flutter tooling can truncate LSP messages for a non-ASCII project path.
if ($taskRoot -match '[^\x00-\x7F]') {
    $taskHasher = [Security.Cryptography.SHA256]::Create()
    $taskHash = ([BitConverter]::ToString($taskHasher.ComputeHash([Text.Encoding]::UTF8.GetBytes($taskRoot)))).Replace('-', '').Substring(0, 12)
    $taskHasher.Dispose()
    $taskWorkingPath = Join-Path $env:USERPROFILE "baiqau-$taskHash"
    if (-not (Test-Path -LiteralPath $taskWorkingPath)) {
        New-Item -ItemType Junction -Path $taskWorkingPath -Value $taskRoot | Out-Null
    } elseif ((Get-Item -LiteralPath $taskWorkingPath).Target -ne $taskRoot) {
        throw "The helper path already points to a different project: $taskWorkingPath"
    }
}
Push-Location -LiteralPath $taskWorkingPath
try {
    & flutter @FlutterArguments
    $taskExitCode = $LASTEXITCODE
} finally {
    Pop-Location
}
exit $taskExitCode
