$defaultDate = Get-Date -Format "yyyyMMdd"
Write-Host "请输入发布日 (默认为本日: $defaultDate): " -NoNewline
$inputDate = Read-Host

if ([string]::IsNullOrWhiteSpace($inputDate)) {
    $inputDate = $defaultDate
} else {
    $parsedDate = [datetime]::MinValue
    $isValid = [datetime]::TryParseExact($inputDate, "yyyyMMdd", $null, [System.Globalization.DateTimeStyles]::None, [ref]$parsedDate)
    
    if (-not $isValid) {
        Write-Error "错误: 发布日格式不正确，必须为 yyyyMMdd 格式（例如 20260606）。"
        exit 1
    }
}

$version = "v{0}.{1}.{2}" -f $inputDate.Substring(0, 4), [int]$inputDate.Substring(4, 2), [int]$inputDate.Substring(6, 2)

if (git status --porcelain) {
    Write-Error "错误: 存在未提交的改动，请先提交后再发布。"
    git status --short
    exit 1
}

if ([int](git rev-list --count '@{u}..HEAD') -gt 0) {
    Write-Error "错误: 存在未推送的提交，请先执行 git push。"
    exit 1
}

git tag $version
git push origin main --tags

Write-Host "已成功创建并推送标签: $version" -ForegroundColor Green
