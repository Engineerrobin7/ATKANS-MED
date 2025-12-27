# ATKANS MED API Testing Script
$baseUrl = "http://localhost:5000"
$authToken = ""
$testUserId = ""
$passedTests = 0
$failedTests = 0
$totalTests = 0

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   ATKANS MED API TESTING SUITE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

function Test-API {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Path,
        [hashtable]$Body,
        [string]$Token
    )
    
    $script:totalTests++
    Write-Host "`nTEST $script:totalTests: $Name" -ForegroundColor Yellow
    Write-Host "$Method $Path" -ForegroundColor Gray
    
    try {
        $headers = @{"Content-Type" = "application/json"}
        if ($Token) { $headers["Authorization"] = "Bearer $Token" }
        
        $params = @{
            Uri = "$baseUrl$Path"
            Method = $Method
            Headers = $headers
            TimeoutSec = 10
        }
        
        if ($Body) {
            $params["Body"] = ($Body | ConvertTo-Json)
        }
        
        $response = Invoke-WebRequest @params -ErrorAction Stop
        Write-Host "✅ Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "Response: $($response.Content)" -ForegroundColor White
        
        # Try to parse response
        try {
            $json = $response.Content | ConvertFrom-Json
            if ($json.token) {
                $script:authToken = $json.token
                Write-Host "🔑 Token saved" -ForegroundColor Magenta
            }
            if ($json.user._id) {
                $script:testUserId = $json.user._id
                Write-Host "👤 User ID: $script:testUserId" -ForegroundColor Magenta
            }
        } catch {}
        
        $script:passedTests++
    }
    catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        $script:failedTests++
    }
}

# Run Tests
Test-API -Name "Server Health" -Method "GET" -Path "/"

Test-API -Name "Send OTP" -Method "POST" -Path "/api/auth/send-otp" -Body @{
    phoneNumber = "+919876543210"
    role = "patient"
}

Test-API -Name "Verify OTP" -Method "POST" -Path "/api/auth/verify-otp" -Body @{
    phoneNumber = "+919876543210"
    otp = "123456"
}

Test-API -Name "Get Me" -Method "GET" -Path "/api/auth/me" -Token $authToken

Test-API -Name "Get Users" -Method "GET" -Path "/api/users" -Token $authToken

Test-API -Name "Create User" -Method "POST" -Path "/api/users" -Token $authToken -Body @{
    phoneNumber = "+919999999999"
    role = "doctor"
}

Test-API -Name "Get Stats" -Method "GET" -Path "/api/stats" -Token $authToken

Test-API -Name "Get Access Requests" -Method "GET" -Path "/api/access-requests" -Token $authToken

Test-API -Name "Create Access Request" -Method "POST" -Path "/api/access-requests" -Token $authToken -Body @{
    patientId = "507f1f77bcf86cd799439011"
    reason = "Test"
}

Test-API -Name "Get Patient Requests" -Method "GET" -Path "/api/patient/access-requests" -Token $authToken

Test-API -Name "Update Profile" -Method "PUT" -Path "/api/patient/profile" -Token $authToken -Body @{
    name = "Test User"
}

Test-API -Name "Create Subscription" -Method "POST" -Path "/api/subscription/create" -Body @{
    userId = "507f1f77bcf86cd799439011"
    plan = "monthly"
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RESULTS: ✅ $passedTests/$totalTests | ❌ $failedTests/$totalTests" -ForegroundColor Cyan
$rate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests * 100), 2) } else { 0 }
Write-Host "Success Rate: $rate%" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
