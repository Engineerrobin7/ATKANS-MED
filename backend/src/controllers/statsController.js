const { FirestoreHelper, Collections } = require('../config/firestore');

// @desc    Get stats
// @route   GET /api/stats
// @access  Private
exports.getStats = async (req, res) => {
    try {
        const [patients, doctors, reports, users, accessRequests, subscriptions] = await Promise.all([
            FirestoreHelper.count(Collections.PATIENTS),
            FirestoreHelper.count(Collections.DOCTORS),
            FirestoreHelper.count(Collections.REPORTS),
            FirestoreHelper.count(Collections.USERS),
            FirestoreHelper.count(Collections.ACCESS_REQUESTS),
            FirestoreHelper.count(Collections.SUBSCRIPTIONS)
        ]);

        // Count active users (verified users)
        const activeUsers = await FirestoreHelper.count(Collections.USERS, { isVerified: true });

        res.status(200).json({
            totalUsers: users,
            activeUsers,
            patients,
            doctors,
            reports,
            accessRequests,
            subscriptions,
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        console.error('Get stats error:', error);
        res.status(500).json({ message: error.message });
    }
};