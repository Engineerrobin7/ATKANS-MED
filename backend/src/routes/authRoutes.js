const express = require('express');
const { 
    sendOtp, 
    verifyOtp, 
    getMe,
    requestLoginOTP,
    verifyLoginOTP,
    firebasePhoneLogin,
    googleLogin
} = require('../controllers/authController');
const { protect } = require('../middleware/auth');

const r = express.Router();

/**
 * CUSTOM OTP (EMAIL/SMS)
 */
r.post('/send-otp', sendOtp);
r.post('/verify-otp', verifyOtp);

/**
 * FIREBASE AUTH
 */
r.post('/firebase-phone-login', firebasePhoneLogin);
r.post('/google-login', googleLogin);

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
