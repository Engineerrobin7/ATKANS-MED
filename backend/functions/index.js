const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// ============================================
// EMAIL OTP FUNCTIONS
// ============================================

// Configure email transporter (using Gmail for demo)
// For production, use SendGrid, Mailgun, or AWS SES
const emailTransporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: functions.config().email?.user || "your-email@gmail.com",
        pass: functions.config().email?.password || "your-app-password",
    },
});

// Send OTP via Email
exports.sendEmailOTP = functions.https.onCall(async (data, context) => {
    const { email } = data;

    if (!email) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Email is required"
        );
    }

    try {
        // Generate 6-digit OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();

        // Store OTP in Firestore with expiry
        await admin.firestore().collection("otp_codes").doc(email).set({
            code: otp,
            email: email,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            expiresAt: new Date(Date.now() + 10 * 60 * 1000), // 10 minutes
            verified: false,
        });

        // Send email
        const mailOptions = {
            from: `ATKANS MED <${functions.config().email?.user}>`,
            to: email,
            subject: "Your OTP Code for ATKANS MED",
            html: `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; background: #f4f4f4; padding: 20px; }
            .container { max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 10px; }
            .header { text-align: center; margin-bottom: 30px; }
            .otp-box { background: linear-gradient(135deg, #CDFF00 0%, #A3D900 100%); padding: 20px; border-radius: 10px; text-align: center; margin: 30px 0; }
            .otp-code { font-size: 36px; font-weight: bold; color: #000; letter-spacing: 10px; }
            .footer { text-align: center; color: #666; font-size: 12px; margin-top: 30px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1 style="color: #CDFF00;">ATKANS MED</h1>
              <p style="color: #666;">Your Health, Our Priority</p>
            </div>
            <p>Hello,</p>
            <p>Your One-Time Password (OTP) for login is:</p>
            <div class="otp-box">
              <div class="otp-code">${otp}</div>
            </div>
            <p><strong>This code will expire in 10 minutes.</strong></p>
            <p style="color: #999;">If you didn't request this code, please ignore this email.</p>
            <div class="footer">
              <p>© 2024 ATKANS MED. All rights reserved.</p>
              <p>Your Health Records Platform</p>
            </div>
          </div>
        </body>
        </html>
      `,
        };

        await emailTransporter.sendMail(mailOptions);

        console.log(`OTP sent to ${email}: ${otp}`);
        return {
            success: true,
            message: "OTP sent to your email",
            // Removed OTP from response for security
        };
    } catch (error) {
        console.error("Error sending email OTP:", error);
        throw new functions.https.HttpsError("internal", error.message);
    }
});

// Verify Email OTP
exports.verifyEmailOTP = functions.https.onCall(async (data, context) => {
    const { email, otp } = data;

    if (!email || !otp) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Email and OTP are required"
        );
    }

    try {
        const otpDoc = await admin.firestore()
            .collection("otp_codes")
            .doc(email)
            .get();

        if (!otpDoc.exists) {
            throw new functions.https.HttpsError("not-found", "OTP not found");
        }

        const otpData = otpDoc.data();

        // Check expiry
        if (new Date() > otpData.expiresAt.toDate()) {
            throw new functions.https.HttpsError("deadline-exceeded", "OTP expired");
        }

        // Check if already used
        if (otpData.verified) {
            throw new functions.https.HttpsError(
                "already-exists",
                "OTP already used"
            );
        }

        // Verify OTP
        if (otpData.code !== otp) {
            throw new functions.https.HttpsError(
                "invalid-argument",
                "Invalid OTP"
            );
        }

        // Mark as verified
        await otpDoc.ref.update({ verified: true });

        return { success: true, message: "OTP verified successfully" };
    } catch (error) {
        console.error("Error verifying OTP:", error);
        throw error;
    }
});

// ============================================
// SMS OTP FUNCTIONS (Using Twilio)
// ============================================

// Twilio configuration
const twilioAccountSid = functions.config().twilio?.account_sid;
const twilioAuthToken = functions.config().twilio?.auth_token;
const twilioPhoneNumber = functions.config().twilio?.phone_number;

let twilioClient;
if (twilioAccountSid && twilioAuthToken) {
    twilioClient = require("twilio")(twilioAccountSid, twilioAuthToken);
}

// Send OTP via SMS
exports.sendSMSOTP = functions.https.onCall(async (data, context) => {
    const { phoneNumber } = data;

    if (!phoneNumber) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Phone number is required"
        );
    }

    try {
        // Generate 6-digit OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();

        // Store OTP in Firestore
        await admin.firestore().collection("otp_codes").doc(phoneNumber).set({
            code: otp,
            phoneNumber: phoneNumber,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            expiresAt: new Date(Date.now() + 10 * 60 * 1000),
            verified: false,
        });

        // Send SMS via Twilio
        if (twilioClient) {
            await twilioClient.messages.create({
                body: `Your ATKANS MED OTP is: ${otp}. Valid for 10 minutes.`,
                from: twilioPhoneNumber,
                to: phoneNumber,
            });
            console.log(`SMS OTP sent to ${phoneNumber}`);
        } else {
            console.log(`Twilio not configured. OTP for ${phoneNumber}: ${otp}`);
        }

        return {
            success: true,
            message: "OTP sent to your phone",
            // Removed OTP from response for security
        };
    } catch (error) {
        console.error("Error sending SMS OTP:", error);
        throw new functions.https.HttpsError("internal", error.message);
    }
});

// Verify SMS OTP
exports.verifySMSOTP = functions.https.onCall(async (data, context) => {
    const { phoneNumber, otp } = data;

    if (!phoneNumber || !otp) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Phone number and OTP are required"
        );
    }

    try {
        const otpDoc = await admin.firestore()
            .collection("otp_codes")
            .doc(phoneNumber)
            .get();

        if (!otpDoc.exists) {
            throw new functions.https.HttpsError("not-found", "OTP not found");
        }

        const otpData = otpDoc.data();

        // Check expiry
        if (new Date() > otpData.expiresAt.toDate()) {
            throw new functions.https.HttpsError("deadline-exceeded", "OTP expired");
        }

        // Check if already used
        if (otpData.verified) {
            throw new functions.https.HttpsError(
                "already-exists",
                "OTP already used"
            );
        }

        // Verify OTP
        if (otpData.code !== otp) {
            throw new functions.https.HttpsError(
                "invalid-argument",
                "Invalid OTP"
            );
        }

        // Mark as verified
        await otpDoc.ref.update({ verified: true });

        return { success: true, message: "OTP verified successfully" };
    } catch (error) {
        console.error("Error verifying SMS OTP:", error);
        throw error;
    }
});

// ============================================
// OTHER FUNCTIONS
// ============================================

// Create user profile when new user signs up
exports.createUserProfile = functions.auth.user().onCreate(async (user) => {
    try {
        const userProfile = {
            uid: user.uid,
            email: user.email || "",
            phoneNumber: user.phoneNumber || "",
            name: user.displayName || user.email?.split("@")[0] || "User",
            role: "patient",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            profilePictureUrl: user.photoURL || null,
        };

        await admin.firestore().collection("users").doc(user.uid).set(userProfile);
        console.log(`User profile created for ${user.uid}`);
        return null;
    } catch (error) {
        console.error("Error creating user profile:", error);
        return null;
    }
});

// Clean up expired OTPs (runs daily)
exports.cleanupExpiredOTPs = functions.pubsub
    .schedule("every 24 hours")
    .onRun(async (context) => {
        const now = new Date();
        const snapshot = await admin.firestore()
            .collection("otp_codes")
            .where("expiresAt", "<=", now)
            .get();

        const batch = admin.firestore().batch();
        snapshot.docs.forEach((doc) => {
            batch.delete(doc.ref);
        });

        await batch.commit();
        console.log(`Deleted ${snapshot.size} expired OTPs`);
        return null;
    });
