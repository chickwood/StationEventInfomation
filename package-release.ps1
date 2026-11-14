param(
    [string]$DateTag = (Get-Date -Format "yyyyMMdd")
)

if ($DateTag -notmatch '^\d{8}$') {
    Write-Error "错误: 日期格式不正确，必须为 yyyyMMdd 格式（例如 20260606）。"
    exit 1
}

$files = @()
foreach ($f in @("station_data_xyz.bin", "event_data.ndjson")) {
    if (Test-Path -LiteralPath $f -PathType Leaf) {
        $files += $f
    } else {
        Write-Warning "跳过不存在的文件: $f"
    }
}

if ($files.Count -eq 0) {
    Write-Warning "没有可打包的文件，跳过压缩。"
    exit 0
}

$sumLines = foreach ($f in $files) {
    $hash = (Get-FileHash -LiteralPath $f -Algorithm SHA256).Hash.ToLowerInvariant()
    "$hash  $f"
}
[System.IO.File]::WriteAllText(
    (Join-Path (Get-Location) "SHA256SUMS"),
    (($sumLines -join "`n") + "`n"),
    (New-Object System.Text.UTF8Encoding($false))
)

$zipFiles = $files + "SHA256SUMS"
$tmpZip = [System.IO.Path]::GetRandomFileName() + ".zip"
$finalZip = "station-event.$DateTag.zip"

Compress-Archive -Path $zipFiles -DestinationPath $tmpZip -Force
Move-Item -LiteralPath $tmpZip -Destination $finalZip -Force

Write-Host "已生成压缩包: $finalZip" -ForegroundColor Green
