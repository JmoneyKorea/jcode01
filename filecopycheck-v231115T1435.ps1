# 출발지와 목적지 폴더 경로 설정
$sourcePath = "C:\cmclient"
$destinationPath = "D:\cmclient"

# 오류 보고서를 저장할 폴더 경로 설정
$errorReportPath = "C:\temp\ErrorReport"

# 보고서 파일명 생성
$errorReportFileName = "jmoneyreport_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".txt"
$errorReportFilePath = Join-Path -Path $errorReportPath -ChildPath $errorReportFileName

# 함수 정의: 폴더 내의 파일 사이즈 계산
function Get-FolderSize {
    param (
        [string]$folderPath
    )
    Get-ChildItem -Recurse $folderPath | Measure-Object -Property Length -Sum
}

# 출발지와 목적지 폴더의 파일 및 폴더 수 확인
$sourceFiles = Get-ChildItem -Recurse $sourcePath | Where-Object { $_.PSIsContainer -eq $false }
$destinationFiles = Get-ChildItem -Recurse $destinationPath | Where-Object { $_.PSIsContainer -eq $false }

$sourceFolders = Get-ChildItem -Recurse $sourcePath | Where-Object { $_.PSIsContainer -eq $true }
$destinationFolders = Get-ChildItem -Recurse $destinationPath | Where-Object { $_.PSIsContainer -eq $true }

# 출발지와 목적지 각각에 대한 정보 출력
Write-Output "출발지: $sourcePath"
Write-Output "목적지: $destinationPath"

# 출발지와 목적지 각각에 대해서 전체 파일 사이즈/파일 수량/폴더 수량 계산 및 출력
$sourceSize = Get-FolderSize -folderPath $sourcePath
$destinationSize = Get-FolderSize -folderPath $destinationPath

Write-Output "출발지 전체 파일 사이즈: $($sourceSize.Sum) bytes"
Write-Output "출발지 전체 파일 수량: $($sourceFiles.Count)"
Write-Output "출발지 전체 폴더 수량: $($sourceFolders.Count)"
Write-Output ""
Write-Output "목적지 전체 파일 사이즈: $($destinationSize.Sum) bytes"
Write-Output "목적지 전체 파일 수량: $($destinationFiles.Count)"
Write-Output "목적지 전체 폴더 수량: $($destinationFolders.Count)"
Write-Output ""

# 스크립트 시작 시간 기록
$startTime = Get-Date

# 정합성 체크 및 오류 보고서 생성
$hasErrors = $false

# 출발지에서 목적지로 파일을 복사한 경우, 목적지에만 존재하는 파일 체크
foreach ($destinationFile in $destinationFiles) {
    $sourceFile = Join-Path -Path $sourcePath -ChildPath $destinationFile.FullName.Substring($destinationPath.Length)

    if (!(Test-Path $sourceFile)) {
        $errorInfo = "오류 발생: 파일이 목적지에만 있음 - $($sourceFile) -> $($destinationFile.FullName)"
        Write-Output $errorInfo
        Add-Content -Path $errorReportFilePath -Value $errorInfo
        $hasErrors = $true
    }
}

# 출발지에서 목적지로 파일을 복사한 경우, 소스에는 없는데 목적지에 있는 파일 체크
foreach ($sourceFile in $sourceFiles) {
    $destinationFile = Join-Path -Path $destinationPath -ChildPath $sourceFile.FullName.Substring($sourcePath.Length)

    if (!(Test-Path $destinationFile)) {
        $errorInfo = "오류 발생: 파일이 목적지에 없음 - $($sourceFile.FullName) -> $($destinationFile)"
        Write-Output $errorInfo
        Add-Content -Path $errorReportFilePath -Value $errorInfo
        $hasErrors = $true
    } elseif ((Get-Item $sourceFile.FullName).Length -ne (Get-Item $destinationFile).Length) {
        $errorInfo = "오류 발생: 파일 크기가 다름 - $($sourceFile.FullName) -> $($destinationFile)"
        Write-Output $errorInfo
        Add-Content -Path $errorReportFilePath -Value $errorInfo
        $hasErrors = $true
    }
}

# 스크립트 종료 시간 기록
$endTime = Get-Date

# 실행 시간 계산
$executionTime = $endTime - $startTime
Write-Output "스크립트 실행 시간: $($executionTime.TotalSeconds) 초"

if (-not $hasErrors) {
    Write-Output "틀린 것이 없습니다."
}

# 변수와 파라미터 초기화
$sourcePath = $null
$destinationPath = $null
$errorReportPath = $null
$errorReportFileName = $null
$errorReportFilePath = $null

# 함수 초기화
Remove-Item function:\Get-FolderSize -Force

# 'errorInfo' 변수 확인 후 초기화 및 삭제
if ($errorInfo) {
    $errorInfo = $null
    Remove-Variable -Name errorInfo -ErrorAction SilentlyContinue
}

# 스크립트 전체 변수 초기화
Remove-Variable -Name sourceFiles, destinationFiles, sourceFolders, destinationFolders, sourceSize, destinationSize, sourceFile, destinationFile, hasErrors
