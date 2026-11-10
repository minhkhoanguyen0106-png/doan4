param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9-]{1,64}$')]
    [string]$DeviceCode,

    [string]$BaseUrl = 'http://localhost:8080',

    [ValidateRange(5, 86400)]
    [int]$IntervalSeconds = 30
)

$ErrorActionPreference = 'Stop'
$BaseUrl = $BaseUrl.TrimEnd('/')
$secureToken = Read-Host 'Device token' -AsSecureString
$tokenPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)

try {
    $deviceToken = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($tokenPointer)
    $random = [System.Random]::new()
    $endpoint = "$BaseUrl/api/device-ingest/$DeviceCode/measurements"

    Write-Host "Sending simulated measurements to $endpoint every $IntervalSeconds seconds. Press Ctrl+C to stop."

    while ($true) {
        $now = [DateTime]::UtcNow
        $payload = @{
            messageId = "$DeviceCode-$([Guid]::NewGuid().ToString('N'))"
            measuredAt = $now.ToString('o')
            readings = @{
                temperatureC = [Math]::Round(25 + $random.NextDouble() * 7, 2)
                ph = [Math]::Round(6.5 + $random.NextDouble() * 1.5, 2)
                dissolvedOxygenMgL = [Math]::Round(5 + $random.NextDouble() * 3, 2)
                turbidityNtu = [Math]::Round(1 + $random.NextDouble() * 10, 2)
                tdsMgL = [Math]::Round(100 + $random.NextDouble() * 250, 2)
            }
        } | ConvertTo-Json -Depth 4

        try {
            $response = Invoke-RestMethod -Method Post -Uri $endpoint `
                -Headers @{ 'X-Device-Token' = $deviceToken } `
                -ContentType 'application/json' -Body $payload -TimeoutSec 15
            Write-Host "[$($now.ToString('HH:mm:ss')) UTC] accepted $($response.messageId) ($($response.assessmentLevel))"
        }
        catch {
            Write-Warning "[$($now.ToString('HH:mm:ss')) UTC] ingest failed: $($_.Exception.Message)"
        }

        Start-Sleep -Seconds $IntervalSeconds
    }
}
finally {
    if ($tokenPointer -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($tokenPointer)
    }
    $deviceToken = $null
    $secureToken.Dispose()
}
