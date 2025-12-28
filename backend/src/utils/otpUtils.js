const nodemailer = require('nodemailer');
const otpGenerator = require('otp-generator');
const https = require('https');

/**
 * Sends mail via Brevo API (No domain required, bypasses SMTP blocks)
 */
const sendViaBrevo = (mailOptions) => {
    return new Promise((resolve, reject) => {
        const data = JSON.stringify({
            sender: {
                name: 'ATKANS MED',
                email: process.env.EMAIL_USER // Uses your validated Gmail as the sender
            },
            to: [{ email: mailOptions.to }],
            subject: mailOptions.subject,
            htmlContent: mailOptions.html,
        });

        const options = {
            hostname: 'api.brevo.com',
            port: 443,
            path: '/v3/smtp/email',
            method: 'POST',
            headers: {
                'accept': 'application/json',
                'api-key': process.env.BREVO_API_KEY,
                'content-type': 'application/json',
                'content-length': Buffer.byteLength(data),
            },
        };

        const req = https.request(options, (res) => {
            let responseData = '';
            res.on('data', (chunk) => { responseData += chunk; });
            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    resolve(true);
                } else {
                    reject(new Error(`Brevo API Error: ${responseData}`));
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
                        <p style="color: #666; font-size: 16px; line-height: 1.6;">Your verification code for ATKANS MED is:</p>
                        <div style="background-color: #f0f0f0; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
                            <span style="font-size: 32px; font-weight: bold; color: #667eea; letter-spacing: 5px;">${otp}</span>
                        </div>
                        <p style="color: #999; font-size: 14px;">This code will expire in ${process.env.OTP_EXPIRY_MINUTES || 10} minutes.</p>
                        <p style="color: #666; font-size: 14px; line-height: 1.6;">If you didn't request this code, please ignore this email.</p>
                        <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
                        <p style="color: #999; font-size: 12px; text-align: center;">© 2024 ATKANS MED. All rights reserved.</p>
                    </div>
                </div>`,
            text: `Your ATKANS MED verification code is: ${otp}`,
        };

        // PRIORITY 1: Brevo API (Supports random emails without a domain)
        if (process.env.BREVO_API_KEY) {
            console.log('📬 Attempting to send OTP via Brevo API...');
            await sendViaBrevo(mailOptions);
            console.log(`✉️ OTP email sent via Brevo API to ${email}`);
            return true;
        }

        // PRIORITY 2: SMTP Fallback
        console.log('📬 Attempting to send OTP via SMTP Fallback...');
        await emailTransporter.sendMail(mailOptions);
        console.log(`✉️ OTP email sent via SMTP to ${email}`);
        return true;
    } catch (error) {
        console.error(`❌ Error sending OTP email to ${email}:`, error.message);
        throw new Error('Email delivery failed: ' + error.message);
    }
};

/**
 * Sends OTP via SMS using Twilio
 */
const sendOTPSMS = async (phone, otp) => {
    try {
        if (!process.env.TWILIO_ACCOUNT_SID || !process.env.TWILIO_AUTH_TOKEN) {
            console.warn('⚠️ Twilio not configured.');
            return false;
        }
        const twilio = require('twilio');
        const client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
        await client.messages.create({
            body: `Your ATKANS MED code is: ${otp}`,
            from: process.env.TWILIO_PHONE_NUMBER,
            to: phone,
        });
        return true;
    } catch (error) {
        console.error(`❌ SMS Error:`, error.message);
        return false;
    }
};

const sendOTP = async (contact, otp, method = 'email', userName = 'User') => {
    if (method === 'email') return sendOTPEmail(contact, otp, userName);
    if (method === 'sms') return sendOTPSMS(contact, otp);
    throw new Error('Invalid method');
};

module.exports = { generateOTP, sendOTP, sendOTPEmail, sendOTPSMS };
