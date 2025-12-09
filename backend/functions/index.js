const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Authentication Trigger: Create User Profile in Firestore
exports.createUserProfile = functions.auth.user().onCreate(async (user) => {
    const { uid, email, phoneNumber } = user;

    // Default role is Patient, unless specified in custom claims (which we can't easily do on client)
    // Or we can assume signup creates a skeletal record we update later.

    try {
        await admin.firestore().collection("users").doc(uid).set({
            email: email || "",
            phoneNumber: phoneNumber || "",
            role: "patient", // Default, can be updated
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            isActive: true,
        });
        console.log(`User profile created for ${uid}`);
    } catch (error) {
        console.error("Error creating user profile:", error);
    }
});

// Doctor Access Request
exports.requestDoctorAccess = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
    }

    const { targetDoctorId, patientId } = data;
    // Logic to create a request record
    return { success: true, message: "Request sent" };
});

// Admin Dashboard stats (Example Http Trigger)
exports.getDashboardStats = functions.https.onRequest(async (req, res) => {
    // Check for admin secret or auth token (simplified here)
    const usersCount = (await admin.firestore().collection('users').count().get()).data().count;
    res.json({
        users: usersCount,
        doctors: 0, // Placeholder
        revenue: 0 // Placeholder
    });
});
