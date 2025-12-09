const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Create user profile when new user signs up
exports.createUserProfile = functions.auth.user().onCreate(async (user) => {
    try {
        const userProfile = {
            uid: user.uid,
            email: user.email || "",
            phoneNumber: user.phoneNumber || "",
            name: user.displayName || user.email?.split("@")[0] || "User",
            role: "patient", // Default role
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

// Handle doctor access request
exports.requestDoctorAccess = functions.https.onCall(async (data, context) => {
    // Verify authentication
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "User must be authenticated"
        );
    }

    const { patientId, reason, durationHours } = data;

    if (!patientId || !reason || !durationHours) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Missing required fields"
        );
    }

    try {
        const doctorId = context.auth.uid;

        // Get doctor and patient info
        const doctorDoc = await admin.firestore()
            .collection("users")
            .doc(doctorId)
            .get();
        const patientDoc = await admin.firestore()
            .collection("users")
            .doc(patientId)
            .get();

        if (!doctorDoc.exists || !patientDoc.exists) {
            throw new functions.https.HttpsError("not-found", "User not found");
        }

        // Create access request
        const accessRequest = {
            doctorId: doctorId,
            doctorName: doctorDoc.data().name,
            patientId: patientId,
            patientName: patientDoc.data().name,
            reason: reason,
            requestedAt: admin.firestore.FieldValue.serverTimestamp(),
            status: "pending",
            durationHours: durationHours,
        };

        const docRef = await admin.firestore()
            .collection("access_requests")
            .add(accessRequest);

        // Send notification to patient (FCM)
        // TODO: Implement FCM notification

        return { success: true, requestId: docRef.id };
    } catch (error) {
        console.error("Error creating access request:", error);
        throw new functions.https.HttpsError("internal", error.message);
    }
});

// Auto-expire access requests
exports.expireAccessRequests = functions.pubsub
    .schedule("every 1 hours")
    .onRun(async (context) => {
        const now = admin.firestore.Timestamp.now();
        const snapshot = await admin.firestore()
            .collection("access_requests")
            .where("status", "==", "approved")
            .where("expiresAt", "<=", now.toDate().toISOString())
            .get();

        const batch = admin.firestore().batch();
        snapshot.docs.forEach((doc) => {
            batch.update(doc.ref, { status: "expired" });
        });

        await batch.commit();
        console.log(`Expired ${snapshot.size} access requests`);
        return null;
    });

// Get admin dashboard statistics
exports.getDashboardStats = functions.https.onRequest(async (req, res) => {
    try {
        // In production, verify admin role here
        const usersSnapshot = await admin.firestore()
            .collection("users")
            .count()
            .get();
        const reportsSnapshot = await admin.firestore()
            .collection("medical_reports")
            .count()
            .get();
        const requestsSnapshot = await admin.firestore()
            .collection("access_requests")
            .where("status", "==", "pending")
            .count()
            .get();

        const doctorsSnapshot = await admin.firestore()
            .collection("users")
            .where("role", "==", "doctor")
            .count()
            .get();

        const stats = {
            totalUsers: usersSnapshot.data().count,
            totalReports: reportsSnapshot.data().count,
            pendingRequests: requestsSnapshot.data().count,
            totalDoctors: doctorsSnapshot.data().count,
            timestamp: new Date().toISOString(),
        };

        res.json(stats);
    } catch (error) {
        console.error("Error fetching stats:", error);
        res.status(500).json({ error: error.message });
    }
});

// Send notification when access request is approved
exports.onAccessApproved = functions.firestore
    .document("access_requests/{requestId}")
    .onUpdate(async (change, context) => {
        const before = change.before.data();
        const after = change.after.data();

        // Check if status changed to approved
        if (before.status !== "approved" && after.status === "approved") {
            // Send FCM notification to doctor
            const doctorDoc = await admin.firestore()
                .collection("users")
                .doc(after.doctorId)
                .get();

            // TODO: Send FCM notification
            console.log(`Access approved for doctor ${after.doctorId}`);
        }

        return null;
    });
