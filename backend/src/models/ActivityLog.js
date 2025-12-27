const mongoose = require('mongoose');

const activityLogSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
    },
    action: { type: String, required: true }, // e.g. "VIEW_RECORD", "ADD_PRESCRIPTION"
    targetModel: { type: String }, // e.g. "Patient", "Report"
    targetId: { type: mongoose.Schema.Types.ObjectId },
    details: { type: String },
    ipAddress: { type: String },
    userAgent: { type: String }
}, { timestamps: { createdAt: true, updatedAt: false } });

const ActivityLog = mongoose.model('ActivityLog', activityLogSchema);
module.exports = ActivityLog;
