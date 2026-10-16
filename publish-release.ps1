$defaultTag = Get-Date -Format "yyyyMMdd"
$tag = Read-Host "请输入版本号 (默认: $defaultTag)"

if ([string]::IsNullOrWhiteSpace($tag)) {
    $tag = $defaultTag
} else {
    $parsedDate = [datetime]::MinValue
    $isValid = [datetime]::TryParseExact($tag, "yyyyMMdd", $null, [System.Globalization.DateTimeStyles]::None, [ref]$parsedDate)
    
    if (-not $isValid) {
        Write-Error "错误: 输入的版本号格式不正确，必须为 yyyyMMdd 格式（例如 20260606）。"
        exit 1
    }
}

git add .
git commit -m "release: $tag"
git tag "v$tag"
git push origin main --tags

Write-Host "已成功创建并推送标签: v$tag" -ForegroundColor Green
