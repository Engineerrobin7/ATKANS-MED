const http = require('http');

const BASE_URL = 'http://localhost:5000';
let authToken = '';
let testUserId = '';

// Helper function to make HTTP requests
function makeRequest(method, path, data = null, token = null) {
    return new Promise((resolve, reject) => {
        const url = new URL(path, BASE_URL);
        const options = {
            method: method,
            headers: {
                'Content-Type': 'application/json',
            }
        };

        if (token) {
            options.headers['Authorization'] = `Bearer ${token}`;
        }

        const req = http.request(url, options, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                try {
                    const response = {
                        status: res.statusCode,
                        headers: res.headers,
                        body: body ? JSON.parse(body) : null
                    };
                    resolve(response);
                } catch (e) {
                    resolve({
                        status: res.statusCode,
                        headers: res.headers,
                        body: body
                    });
                }
            });
        });

        req.on('error', reject);

        if (data) {
            req.write(JSON.stringify(data));
        }

        req.end();
    });
}

// Test functions
async function testServerHealth() {
    console.log('\n========================================');
    console.log('TEST 1: Server Health Check');
    console.log('========================================');
    try {
        const response = await makeRequest('GET', '/');
        console.log('✅ Status:', response.status);
        console.log('📄 Response:', response.body);
        return response.status === 200;
    } catch (error) {
        console.log('❌ Error:', error.message);
        return false;
    }
}

async function testSendOTP() {
    console.log('\n========================================');
    console.log('TEST 2: Send OTP (POST /api/auth/send-otp)');
    console.log('========================================');
    try {
        const response = await makeRequest('POST', '/api/auth/send-otp', {
            phoneNumber: '+919876543210',
            role: 'patient'
        });
        console.log('✅ Status:', response.status);
        console.log('📄 Response:', response.body);
        return response.status === 200 || response.status === 201;
    } catch (error) {
        console.log('❌ Error:', error.message);
        return false;
    }
}

async function testVerifyOTP() {
    console.log('\n========================================');
    console.log('TEST 3: Verify OTP (POST /api/auth/verify-otp)');
    console.log('========================================');
    try {
        const response = await makeRequest('POST', '/api/auth/verify-otp', {
            phoneNumber: '+919876543210',
            otp: '123456'
        });
        console.log('✅ Status:', response.status);
        console.log('📄 Response:', response.body);

        if (response.body && response.body.token) {
            authToken = response.body.token;
            console.log('🔑 Auth token saved for subsequent requests');
        }
        if (response.body && response.body.user && response.body.user._id) {
            testUserId = response.body.user._id;
            console.log('👤 User ID saved:', testUserId);
        }
        return response.status === 200 || response.status === 201;
    } catch (error) {
        console.log('❌ Error:', error.message);
        return false;
    }
}

async function testGetMe() {
    console.log('\n========================================');
    console.log('TEST 4: Get Current User (GET /api/auth/me)');
    console.log('========================================');
    try {
        const response = await makeRequest('GET', '/api/auth/me', null, authToken);
        console.log('✅ Status:', response.status);
        console.log('📄 Response:', response.body);
        return response.status === 200;
    } catch (error) {
        console.log('❌ Error:', error.message);
        return false;
    }
}

async function testGetUsers() {
    console.log('\n========================================');
    console.log('TEST 5: Get All Users (GET /api/users)');
    console.log('========================================');
    try {
        const response = await makeRequest('GET', '/api/users', null, authToken);
        console.log('✅ Status:', response.status);
        console.log('📄 Response:', response.body);
        return response.status === 200;
    } catch (error) {
        console.log('❌ Error:', error.message);
        return false;
    }
}

async function testCreateUser() {
    console.log('\n========================================');
    console.log('TEST 6: Create User (POST /api/users)');
    console.log('========================================');
    try {
        const response = await makeRequest('POST', '/api/users', {
            phoneNumber: '+919999999999',
            role: 'doctor',
            name: 'Dr. Test Doctor',
            email: 'test.doctor@example.com'
        }, authToken);
        console.log('✅ Status:', response.status);
        console.log('📄 Response:', response.body);
        return response.status === 200 || response.status === 201;
    } catch (error) {
        console.log('❌ Error:', error.message);
        return false;
    }
}

async function testGetStats() {
    console.log('\n========================================');
    console.log('TEST 7: Get Statistics (GET /api/stats)');
    console.log('========================================');
    try {
        const response = await makeRequest('GET', '/api/stats', null, authToken);
        console.log('✅ Status:', response.status);
        console.log('📄 Response:', response.body);
        return response.status === 200;
    } catch (error) {
        console.log('❌ Error:', error.message);
        return false;
    }
}

async function testGetAccessRequests() {
    console.log('\n========================================');
    console.log('TEST 8: Get Access Requests (GET /api/access-requests)');
    console.log('========================================');
    try {
        const response = await makeRequest('GET', '/api/access-requests', null, authToken);
        console.log('✅ Status:', response.status);
        console.log('📄 Response:', response.body);
        return response.status === 200;
    } catch (error) {
        console.log('❌ Error:', error.message);
        return false;
    }
}

async function testCreateAccessRequest() {
    console.log('\n========================================');
    console.log('TEST 9: Create Access Request (POST /api/access-requests)');
    console.log('========================================');
    try {
        const response = await makeRequest('POST', '/api/access-requests', {
            patientId: testUserId || '507f1f77bcf86cd799439011',
            reason: 'Medical consultation',
            duration: 24
        }, authToken);
        console.log('✅ Status:', response.status);
        console.log('📄 Response:', response.body);
        return response.status === 200 || response.status === 201;
    } catch (error) {
        console.log('❌ Error:', error.message);
        return false;
    }
}

async function testGetPatientAccessRequests() {
    console.log('\n========================================');
    console.log('TEST 10: Get Patient Access Requests (GET /api/patient/access-requests)');
    console.log('========================================');
    try {
        const response = await makeRequest('GET', '/api/patient/access-requests', null, authToken);
        console.log('✅ Status:', response.status);
        console.log('📄 Response:', response.body);
        return response.status === 200;
    } catch (error) {
        console.log('❌ Error:', error.message);
        return false;
    }
}

async function testUpdateProfile() {
    console.log('\n========================================');
    console.log('TEST 11: Update Patient Profile (PUT /api/patient/profile)');
    console.log('========================================');
    try {
        const response = await makeRequest('PUT', '/api/patient/profile', {
            name: 'Updated Patient Name',
            email: 'updated.patient@example.com'
        }, authToken);
        console.log('✅ Status:', response.status);
        console.log('📄 Response:', response.body);
        return response.status === 200;
    } catch (error) {
        console.log('❌ Error:', error.message);
        return false;
    }
}

async function testCreateSubscription() {
    console.log('\n========================================');
    console.log('TEST 12: Create Subscription (POST /api/subscription/create)');
    console.log('========================================');
    try {
        const response = await makeRequest('POST', '/api/subscription/create', {
            userId: testUserId || '507f1f77bcf86cd799439011',
            planType: 'monthly',
            amount: 99
        });
        console.log('✅ Status:', response.status);
        console.log('📄 Response:', response.body);
        return response.status === 200 || response.status === 201;
    } catch (error) {
        console.log('❌ Error:', error.message);
        return false;
    }
}

// Main test runner
async function runAllTests() {
    console.log('\n╔════════════════════════════════════════╗');
    console.log('║   ATKANS MED API TESTING SUITE        ║');
    console.log('╚════════════════════════════════════════╝');

    const results = {
        passed: 0,
        failed: 0,
        total: 0
    };

    const tests = [
        { name: 'Server Health', fn: testServerHealth },
        { name: 'Send OTP', fn: testSendOTP },
        { name: 'Verify OTP', fn: testVerifyOTP },
        { name: 'Get Me', fn: testGetMe },
        { name: 'Get Users', fn: testGetUsers },
        { name: 'Create User', fn: testCreateUser },
        { name: 'Get Stats', fn: testGetStats },
        { name: 'Get Access Requests', fn: testGetAccessRequests },
        { name: 'Create Access Request', fn: testCreateAccessRequest },
        { name: 'Get Patient Access Requests', fn: testGetPatientAccessRequests },
        { name: 'Update Profile', fn: testUpdateProfile },
        { name: 'Create Subscription', fn: testCreateSubscription }
    ];

    for (const test of tests) {
        results.total++;
        const passed = await test.fn();
        if (passed) {
            results.passed++;
        } else {
            results.failed++;
        }
        // Wait a bit between tests
        await new Promise(resolve => setTimeout(resolve, 500));
    }

    console.log('\n╔════════════════════════════════════════╗');
    console.log('║          TEST RESULTS SUMMARY          ║');
    console.log('╚════════════════════════════════════════╝');
    console.log(`\n✅ Passed: ${results.passed}/${results.total}`);
    console.log(`❌ Failed: ${results.failed}/${results.total}`);
    console.log(`📊 Success Rate: ${((results.passed / results.total) * 100).toFixed(2)}%\n`);
}

// Run tests
runAllTests().catch(console.error);
