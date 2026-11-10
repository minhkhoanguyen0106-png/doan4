$ErrorActionPreference = 'Stop'
$dbUsername = [Environment]::GetEnvironmentVariable('DB_USERNAME', 'Process')
if ([string]::IsNullOrWhiteSpace($dbUsername)) { $dbUsername = [Environment]::GetEnvironmentVariable('DB_USERNAME', 'User') }
if ([string]::IsNullOrWhiteSpace($dbUsername)) { $dbUsername = 'doan4_app' }
$dbPassword = [Environment]::GetEnvironmentVariable('DB_PASSWORD', 'Process')
if ([string]::IsNullOrWhiteSpace($dbPassword)) { $dbPassword = [Environment]::GetEnvironmentVariable('DB_PASSWORD', 'User') }
if ([string]::IsNullOrWhiteSpace($dbPassword)) { throw 'DB_PASSWORD is missing. Set it in your user environment or run the local MySQL setup.' }
$env:DB_USERNAME = $dbUsername
$env:DB_PASSWORD = $dbPassword
if ([string]::IsNullOrWhiteSpace($env:DB_URL)) { $env:DB_URL = 'jdbc:mysql://localhost:3306/fish_pond_management?serverTimezone=UTC' }
Set-Location $PSScriptRoot
& .\mvnw.cmd spring-boot:run
exit $LASTEXITCODE
