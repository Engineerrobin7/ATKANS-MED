const nodemailer = require('nodemailer');
const otpGenerator = require('otp-generator');
const https = require('https');

/**
 * Sends mail via Resend API (Bypasses SMTP port blocks)
 */
const sendViaResend = (mailOptions) => {
    return new Promise((resolve, reject) => {
        const data = JSON.stringify({
            from: 'onboarding@resend.dev',
            to: mailOptions.to,
            subject: mailOptions.subject,
            html: mailOptions.html,
        });

        const options = {
            hostname: 'api.resend.com',
            port: 443,
            path: '/emails',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${process.env.RESEND_API_KEY}`,
                'Content-Length': Buffer.byteLength(data),
            },
        };

        const req = https.request(options, (res) => {
            let responseData = '';
            res.on('data', (chunk) => { responseData += chunk; });
            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    resolve(true);
                } else {
                    reject(new Error(`Resend API Error: ${responseData}`));
                }
            });
        });

        req.on('error', (error) => reject(error));
        req.write(data);
        req.end();
    });
};

// Configure Nodemailer transporter (Fallback for local dev)
const emailTransporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    },
});


/**
 * Generates a numeric OTP
 * @param {number} length - The length of the OTP (default: 6)
 * @returns {string} The generated OTP
 */
const generateOTP = (length = parseInt(process.env.OTP_LENGTH || '6')) => {
    return otpGenerator.generate(length, {
        upperCaseAlphabets: false,
        lowerCaseAlphabets: false,
        specialChars: false,
    });
};

/**
 * Sends OTP via email
 * @param {string} email - The recipient's email address
 * @param {string} otp - The OTP to send
 * @param {string} userName - The user's name for personalization
 * @returns {Promise<boolean>} Success status
 */
const sendOTPEmail = async (email, otp, userName = 'User') => {
    try {
        const mailOptions = {
            from: process.env.EMAIL_FROM || process.env.EMAIL_USER || 'onboarding@resend.dev',
            to: email,
            subject: '🔐 Your ATKANS MED Verification Code',
            html: `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9;">
                    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: center; border-radius: 10px 10px 0 0;">
                        <h1 style="margin: 0;">ATKANS MED</h1>
                    </div>
                    <div style="background: white; padding: 30px; border-radius: 0 0 10px 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                        <h2 style="color: #333; margin-top: 0;">Hello ${userName},</h2>
                        <p style="color: #666; font-size: 16px; line-height: 1.6;">
                            Your verification code for ATKANS MED is:
                        </p>
                        <div style="background-color: #f0f0f0; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
                            <span style="font-size: 32px; font-weight: bold; color: #667eea; letter-spacing: 5px;">
                                ${otp}
                            </span>
                        </div>
                        <p style="color: #999; font-size: 14px;">
                            This code will expire in ${process.env.OTP_EXPIRY_MINUTES || 10} minutes.
                        </p>
                        <p style="color: #666; font-size: 14px; line-height: 1.6;">
                            If you didn't request this code, please ignore this email or contact our support team.
                        </p>
                        <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
                        <p style="color: #999; font-size: 12px; text-align: center;">
                            © 2024 ATKANS MED. All rights reserved.
                        </p>
                    </div>
                </div>
            `,
            text: `Your ATKANS MED verification code is: ${otp}\n\nThis code will expire in ${process.env.OTP_EXPIRY_MINUTES || 10} minutes.\n\nIf you didn't request this code, please ignore this email.`,
        };

        // PRIORITY 1: Resend API (Best for Render/Production)
        if (process.env.RESEND_API_KEY) {
            console.log('📬  Attempting to send OTP via Resend API...');
            await sendViaResend(mailOptions);
            console.log(`✉️  OTP email sent via Resend API to ${email}`);
            return true;
        }

        // PRIORITY 2: Nodemailer/Gmail (Fallback for Local Dev)
        console.log('📬  Attempting to send OTP via SMTP Fallback...');
        const sendEmailPromise = emailTransporter.sendMail(mailOptions);
        const timeoutPromise = new Promise((_, reject) =>
            setTimeout(() => reject(new Error('SMTP sending timed out')), 10000)
        );

        await Promise.race([sendEmailPromise, timeoutPromise]);
        console.log(`✉️  OTP email sent via SMTP to ${email}`);
        return true;
    } catch (error) {
        console.error(`❌ Error sending OTP email to ${email}:`, error.message);
        throw new Error('Email delivery failed: ' + error.message);
    }
};

/**
 * Sends OTP via SMS using Twilio
 * @param {string} phone - The recipient's phone number (E.164 format: +country_code_number)
 * @param {string} otp - The OTP to send
 * @returns {Promise<boolean>} Success status
 */
const sendOTPSMS = async (phone, otp) => {
    try {
        // Only attempt SMS if Twilio is configured
        if (!process.env.TWILIO_ACCOUNT_SID || !process.env.TWILIO_AUTH_TOKEN) {
            console.warn('⚠️  Twilio not configured. SMS sending disabled.');
            return false;
        }

        const twilio = require('twilio');
        const client = twilio(
            process.env.TWILIO_ACCOUNT_SID,
            process.env.TWILIO_AUTH_TOKEN
        );

        const message = await client.messages.create({
            body: `Your ATKANS MED verification code is: ${otp}\n\nThis code expires in ${process.env.OTP_EXPIRY_MINUTES || 10} minutes.`,
            from: process.env.TWILIO_PHONE_NUMBER,
            to: phone,
        });

        console.log(`📱 OTP SMS sent successfully to ${phone} (Message SID: ${message.sid})`);
        return true;
    } catch (error) {
        console.error(`❌ Error sending OTP SMS to ${phone}:`, error.message);
        throw new Error('Failed to send OTP SMS');
    }
};

/**
 * Sends OTP via preferred method (email or SMS)
 * @param {string} contact - Email or phone number
 * @param {string} otp - The OTP to send
 * @param {string} method - 'email' or 'sms'
 * @param {string} userName - User's name for personalization
 * @returns {Promise<boolean>} Success status
 */
const sendOTP = async (contact, otp, method = 'email', userName = 'User') => {
    if (method === 'email') {
        return sendOTPEmail(contact, otp, userName);
    } else if (method === 'sms') {
        return sendOTPSMS(contact, otp);
    } else {
        throw new Error('Invalid OTP method. Use "email" or "sms".');
    }
};

module.exports = {
    generateOTP,
    sendOTP,
    sendOTPEmail,
    sendOTPSMS,
};
