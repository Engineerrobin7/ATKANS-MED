const { FirestoreHelper, Collections } = require('../config/firestore');
const jwt = require('jsonwebtoken');
const { generateOTP, sendOTP } = require('../utils/otpUtils');
const bcryptjs = require('bcryptjs');

// Generate JWT
const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '30d',
    });
};

/**
 * Hash OTP for secure storage
 * @param {string} otp - Plain text OTP
 * @returns {Promise<string>} Hashed OTP
 */
const hashOTP = async (otp) => {
    return await bcryptjs.hash(otp, 10);
};

/**
 * Verify OTP against hashed version
 * @param {string} otp - Plain text OTP
 * @param {string} hashedOTP - Hashed OTP from database
 * @returns {Promise<boolean>} True if OTP matches
 */
const verifyHashedOTP = async (otp, hashedOTP) => {
    return await bcryptjs.compare(otp, hashedOTP);
};

// @desc    Send OTP for registration or login
// @route   POST /api/auth/send-otp
// @access  Public
exports.sendOtp = async (req, res) => {
    const { email, phone, role = 'patient', method = 'email' } = req.body;

    // Validate input
    if (!email && !phone) {
        return res.status(400).json({
            success: false,
            message: 'Please provide either an email or a phone number.'
        });
    }

    // Validate OTP method
    if (!['email', 'sms'].includes(method)) {
        return res.status(400).json({
            success: false,
            message: 'Invalid OTP method. Use "email" or "sms".'
        });
    }

    try {
        let user;
        const otp = generateOTP();
        const otpExpiresAt = new Date(Date.now() + (parseInt(process.env.OTP_EXPIRY_MINUTES || '10')) * 60 * 1000);
        const hashedOTP = await hashOTP(otp);

        // Handle email-based OTP
        if (email && method === 'email') {
            // Check if user exists
            const existingUsers = await FirestoreHelper.findAll(Collections.USERS, { email });

            if (existingUsers.length > 0) {
                user = existingUsers[0];
                // Update existing user with new OTP
                await FirestoreHelper.updateById(Collections.USERS, user.id, {
                    otp: hashedOTP,
                    otpExpiresAt,
                });
            } else {
                // Create new user
                user = await FirestoreHelper.create(Collections.USERS, {
                    email,
                    role,
                    otp: hashedOTP,
                    otpExpiresAt,
                    isVerified: false,
                    createdAt: new Date(),
                });
            }

            // Send email OTP
            await sendOTP(email, otp, 'email', email.split('@')[0]);
            console.log(`📧 OTP (${otp}) sent to email: ${email}`);
        }
        // Handle phone-based OTP
        else if (phone && method === 'sms') {
            // Validate phone format (basic check for +country_code_number)
            if (!phone.match(/^\+\d{1,3}\d{1,14}$/)) {
                return res.status(400).json({
                    success: false,
                    message: 'Invalid phone format. Use E.164 format: +country_code_number'
                });
            }

            const existingUsers = await FirestoreHelper.findAll(Collections.USERS, { phone });

            if (existingUsers.length > 0) {
                user = existingUsers[0];
                await FirestoreHelper.updateById(Collections.USERS, user.id, {
                    otp: hashedOTP,
                    otpExpiresAt,
                });
            } else {
                user = await FirestoreHelper.create(Collections.USERS, {
                    phone,
                    role,
                    otp: hashedOTP,
                    otpExpiresAt,
                    isVerified: false,
                    createdAt: new Date(),
                });
            }

            // Send SMS OTP
            await sendOTP(phone, otp, 'sms');
            console.log(`📱 OTP (${otp}) sent to phone: ${phone}`);
        }

        res.status(200).json({
            success: true,
            message: `OTP sent successfully to ${email || phone}`,
            expiresIn: parseInt(process.env.OTP_EXPIRY_MINUTES || '10'),
        });
    } catch (error) {
        console.error('❌ Send OTP Error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Failed to send OTP'
        });
    }
};

// @desc    Verify OTP and complete registration/login
// @route   POST /api/auth/verify-otp
// @access  Public
exports.verifyOtp = async (req, res) => {
    const { email, phone, otp, name, method = 'email' } = req.body;

    // Validate input
    if (!email && !phone) {
        return res.status(400).json({
            success: false,
            message: 'Please provide either an email or a phone number.'
        });
    }

    if (!otp) {
        return res.status(400).json({
            success: false,
            message: 'OTP is required.'
        });
    }

    try {
        let user;
        let searchField = method === 'email' ? 'email' : 'phone';
        let searchValue = email || phone;

        // Find user
        const users = await FirestoreHelper.findAll(Collections.USERS, { [searchField]: searchValue });

        if (users.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'User not found. Send OTP first.'
            });
        }

        user = users[0];

        // Verify OTP
        if (!user.otp) {
            return res.status(400).json({
                success: false,
                message: 'OTP already verified or expired. Please request a new one.'
            });
        }

        const otpMatch = await verifyHashedOTP(otp, user.otp);
        if (!otpMatch) {
            return res.status(400).json({
                success: false,
                message: 'Invalid OTP. Please try again.'
            });
        }

        // Check OTP expiration
        if (user.otpExpiresAt && new Date() > new Date(user.otpExpiresAt)) {
            return res.status(400).json({
                success: false,
                message: 'OTP has expired. Request a new one.'
            });
        }

        // Mark user as verified and clear OTP
        const updatedUser = await FirestoreHelper.updateById(Collections.USERS, user.id, {
            otp: null,
            otpExpiresAt: null,
            isVerified: true,
            lastLoginAt: new Date(),
        });

        // Create or update user profile based on role
        let profile = null;
        if (user.role === 'patient') {
            const existingProfiles = await FirestoreHelper.findAll(Collections.PATIENTS, { userId: user.id });
            if (existingProfiles.length === 0 && name) {
                const patientData = {
                    userId: user.id,
                    name,
                    authorizedDoctors: [],
                    createdAt: new Date(),
                };
                if (phone || user.phone) patientData.phone = phone || user.phone;
                if (email || user.email) patientData.email = email || user.email;
                profile = await FirestoreHelper.create(Collections.PATIENTS, patientData);
            } else if (existingProfiles.length > 0) {
                profile = existingProfiles[0];
            }
        } else if (user.role === 'doctor') {
            const existingProfiles = await FirestoreHelper.findAll(Collections.DOCTORS, { userId: user.id });
            if (existingProfiles.length === 0 && name) {
                const doctorData = {
                    userId: user.id,
                    name,
                    specialty: 'General',
                    createdAt: new Date(),
                };
                if (phone || user.phone) doctorData.phone = phone || user.phone;
                if (email || user.email) doctorData.email = email || user.email;
                profile = await FirestoreHelper.create(Collections.DOCTORS, doctorData);
            } else if (existingProfiles.length > 0) {
                profile = existingProfiles[0];
            }
        }

        const token = generateToken(user.id);

        res.status(200).json({
            success: true,
            message: 'OTP verified successfully!',
            token,
            user: {
                id: user.id,
                email: user.email,
                phone: user.phone,
                name: updatedUser.name || name, // Ensure name is returned
                profileImage: updatedUser.profileImage, // Ensure profileImage is returned
                role: user.role,
                isVerified: true
            }
        });

        console.log(`✅ User ${user.id} verified successfully`);
    } catch (error) {
        console.error('❌ Verify OTP Error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Failed to verify OTP'
        });
    }
};

// @desc    Request OTP for login (2FA)
// @route   POST /api/auth/request-login-otp
// @access  Public
exports.requestLoginOTP = async (req, res) => {
    const { email, phone, method = 'email' } = req.body;

    if (!email && !phone) {
        return res.status(400).json({
            success: false,
            message: 'Please provide either an email or a phone number.'
        });
    }

    try {
        let user;
        const searchField = method === 'email' ? 'email' : 'phone';
        const searchValue = email || phone;

        const users = await FirestoreHelper.findAll(Collections.USERS, { [searchField]: searchValue });

        if (users.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'User not found.'
            });
        }

        user = users[0];

        // Generate and hash OTP
        const otp = generateOTP();
        const otpExpiresAt = new Date(Date.now() + (parseInt(process.env.OTP_EXPIRY_MINUTES || '10')) * 60 * 1000);
        const hashedOTP = await hashOTP(otp);

        // Update user with OTP
        await FirestoreHelper.updateById(Collections.USERS, user.id, {
            loginOTP: hashedOTP,
            loginOTPExpiresAt: otpExpiresAt,
        });

        // Send OTP
        await sendOTP(email || phone, otp, method);

        res.status(200).json({
            success: true,
            message: `Login OTP sent to ${email || phone}`,
            expiresIn: parseInt(process.env.OTP_EXPIRY_MINUTES || '10'),
        });

        console.log(`📧 Login OTP sent to ${email || phone}`);
    } catch (error) {
        console.error('❌ Request Login OTP Error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Failed to send login OTP'
        });
    }
};

// @desc    Verify login OTP
// @route   POST /api/auth/verify-login-otp
// @access  Public
exports.verifyLoginOTP = async (req, res) => {
    const { email, phone, otp, method = 'email' } = req.body;

    if (!email && !phone) {
        return res.status(400).json({
            success: false,
            message: 'Please provide either an email or a phone number.'
        });
    }

    if (!otp) {
        return res.status(400).json({
            success: false,
            message: 'OTP is required.'
        });
    }

    try {
        let user;
        const searchField = method === 'email' ? 'email' : 'phone';
        const searchValue = email || phone;

        const users = await FirestoreHelper.findAll(Collections.USERS, { [searchField]: searchValue });

        if (users.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'User not found.'
            });
        }

        user = users[0];

        // Verify login OTP
        if (!user.loginOTP) {
            return res.status(401).json({
                success: false,
                message: 'Login OTP already verified or expired. Please request a new one.'
            });
        }

        const otpMatch = await verifyHashedOTP(otp, user.loginOTP);
        if (!otpMatch) {
            return res.status(401).json({
                success: false,
                message: 'Invalid OTP. Please try again.'
            });
        }

        // Check OTP expiration
        if (user.loginOTPExpiresAt && new Date() > new Date(user.loginOTPExpiresAt)) {
            return res.status(401).json({
                success: false,
                message: 'OTP has expired. Request a new one.'
            });
        }

        // Clear OTP and update last login
        await FirestoreHelper.updateById(Collections.USERS, user.id, {
            loginOTP: null,
            loginOTPExpiresAt: null,
            lastLoginAt: new Date(),
        });

        const token = generateToken(user.id);

        res.status(200).json({
            success: true,
            message: 'Login successful!',
            user: {
                id: user.id,
                email: user.email,
                phone: user.phone,
                name: user.name,
                profileImage: user.profileImage,
                role: user.role,
                isVerified: user.isVerified
            },
            token
        });

        console.log(`✅ User ${user.id} logged in via OTP`);
    } catch (error) {
        console.error('❌ Verify Login OTP Error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Failed to verify login OTP'
        });
    }
};

const admin = require('../config/firebaseAdmin');

// @desc    Login or Register user via Firebase Phone Auth
// @route   POST /api/auth/firebase-phone-login
// @access  Public
exports.firebasePhoneLogin = async (req, res) => {
    const { idToken, role = 'patient', name } = req.body;

    if (!idToken) {
        return res.status(400).json({
            success: false,
            message: 'Firebase ID token is required.',
        });
    }

    try {
        // Verify the ID token
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const { phone_number: phone, uid: firebaseUId } = decodedToken;

        if (!phone) {
            return res.status(400).json({
                success: false,
                message: 'Phone number not found in Firebase token.',
            });
        }

        let user;
        const existingUsers = await FirestoreHelper.findAll(Collections.USERS, { phone });

        if (existingUsers.length > 0) {
            // User exists, update last login and firebase UID
            user = existingUsers[0];
            await FirestoreHelper.updateById(Collections.USERS, user.id, {
                lastLoginAt: new Date(),
                firebaseUId, // Store or update Firebase UID
            });
        } else {
            // User does not exist, create a new user
            user = await FirestoreHelper.create(Collections.USERS, {
                phone,
                role,
                isVerified: true,
                firebaseUId, // Store Firebase UID
                createdAt: new Date(),
                lastLoginAt: new Date(),
            });
        }
        
        // Create or update user profile based on role
        let profile = null;
        if (user.role === 'patient') {
            const existingProfiles = await FirestoreHelper.findAll(Collections.PATIENTS, { userId: user.id });
            if (existingProfiles.length === 0 && name) {
                const patientData = {
                    userId: user.id,
                    name,
                    authorizedDoctors: [],
                    createdAt: new Date(),
                    phone,
                };
                profile = await FirestoreHelper.create(Collections.PATIENTS, patientData);
            } else if (existingProfiles.length > 0) {
                profile = existingProfiles[0];
            }
        } else if (user.role === 'doctor') {
            const existingProfiles = await FirestoreHelper.findAll(Collections.DOCTORS, { userId: user.id });
            if (existingProfiles.length === 0 && name) {
                const doctorData = {
                    userId: user.id,
                    name,
                    specialty: 'General',
                    createdAt: new Date(),
                    phone
                };
                profile = await FirestoreHelper.create(Collections.DOCTORS, doctorData);
            } else if (existingProfiles.length > 0) {
                profile = existingProfiles[0];
            }
        }


        // Generate our own app-specific JWT token
        const appToken = generateToken(user.id);

        res.status(200).json({
            success: true,
            message: 'Authentication successful!',
            token: appToken,
            user: {
                id: user.id,
                phone: user.phone,
                role: user.role,
                isVerified: user.isVerified,
                name: profile ? profile.name : undefined,
            },
        });

        console.log(`✅ User ${user.id} authenticated via Firebase Phone Auth`);
    } catch (error) {
        console.error('❌ Firebase Phone Login Error:', error);
        if (error.code === 'auth/id-token-expired') {
            return res.status(401).json({
                success: false,
                message: 'Firebase token has expired. Please log in again.',
            });
        }
        if (error.code === 'auth/argument-error') {
            return res.status(401).json({
                success: false,
                message: 'Invalid Firebase token.',
            });
        }
        res.status(500).json({
            success: false,
            message: error.message || 'Failed to authenticate with Firebase.',
        });
    }
};

// @desc    Get Current User Profile
// @route   GET /api/auth/me
// @access  Private
exports.getMe = async (req, res) => {
    try {
        const user = await FirestoreHelper.findById(Collections.USERS, req.user.id);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        let profile = null;
        if (user.role === 'patient') {
            const profiles = await FirestoreHelper.findAll(Collections.PATIENTS, { userId: user.id });
            profile = profiles[0] || null;
        } else if (user.role === 'doctor') {
            const profiles = await FirestoreHelper.findAll(Collections.DOCTORS, { userId: user.id });
            profile = profiles[0] || null;
        }

        res.status(200).json({
            success: true,
            user: {
                id: user.id,
                email: user.email,
                phone: user.phone,
                role: user.role,
                isVerified: user.isVerified
            },
            profile
        });
    } catch (error) {
        console.error('❌ Get Me Error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Failed to fetch user profile'
        });
    }
};
