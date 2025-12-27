const express = require('express');
const { 
    sendOtp, 
    verifyOtp, 
    getMe,
    requestLoginOTP,
    verifyLoginOTP
} = require('../controllers/authController');
const { protect } = require('../middleware/auth');

const r = express.Router();

/**
 * REGISTRATION/SIGNUP ENDPOINTS
 */
// Send OTP for registration
r.post('/send-otp', sendOtp);

// Verify OTP and complete registration
r.post('/verify-otp', verifyOtp);

/**
 * LOGIN ENDPOINTS
 */
// Request OTP for login (2FA)
r.post('/request-login-otp', requestLoginOTP);

// Verify login OTP
r.post('/verify-login-otp', verifyLoginOTP);

/**
 * USER PROFILE ENDPOINT
 */
// Get current user profile (protected)
r.get('/me', protect, getMe);

module.exports = r;
