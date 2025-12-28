const express = require('express');
const {
    sendOtp,
    verifyOtp,
    getMe,
    requestLoginOTP,
    verifyLoginOTP,
    firebasePhoneLogin,
    googleLogin,
    ping
} = require('../controllers/authController');
const { protect } = require('../middleware/auth');

const r = express.Router();

// Root route for API status
r.get('/', (req, res) => res.json({ message: 'Auth module is active' }));

// Connectivity check
r.post('/ping', ping);

/**
 * CUSTOM OTP (EMAIL/SMS)
 */
r.get('/send-otp', (req, res) => res.status(405).json({ message: 'Please use POST request to send OTP' }));
r.post('/send-otp', sendOtp);

r.get('/verify-otp', (req, res) => res.status(405).json({ message: 'Please use POST request to verify OTP' }));
r.post('/verify-otp', verifyOtp);

/**
 * FIREBASE AUTH
 */
r.get('/firebase-phone-login', (req, res) => res.status(405).json({ message: 'Please use POST request for phone login' }));
r.post('/firebase-phone-login', firebasePhoneLogin);

r.get('/google-login', (req, res) => res.status(405).json({ message: 'Please use POST request for google login' }));
r.post('/google-login', googleLogin);

/**
 * LOGIN ENDPOINTS
 */
// Request OTP for login (2FA)
r.get('/request-login-otp', (req, res) => res.status(405).json({ message: 'Please use POST request for login OTP' }));
r.post('/request-login-otp', requestLoginOTP);


// Verify login OTP
r.get('/verify-login-otp', (req, res) => res.status(405).json({ message: 'Please use POST request to verify login OTP' }));
r.post('/verify-login-otp', verifyLoginOTP);

/**
 * USER PROFILE ENDPOINT
 */
// Get current user profile (protected)
r.get('/me', protect, getMe);

module.exports = r;
