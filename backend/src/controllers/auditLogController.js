const ActivityLog = require('../models/ActivityLog');

// @desc    Get all activity logs
// @route   GET /api/audit-logs
// @access  Private
exports.getAuditLogs = async (req, res) => {
    try {
        const logs = await ActivityLog.find().sort({ timestamp: -1 });
        res.status(200).json(logs);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
