const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
    patient: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Patient',
        required: true
    },
    uploadedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User', // Could be Patient or Doctor
        required: true
    },
    title: { type: String, required: true },
    type: {
        type: String,
        enum: ['Blood Test', 'X-Ray', 'MRI', 'CT Scan', 'Pathology', 'Prescription', 'Other'],
        default: 'Other'
    },
    fileUrl: { type: String, required: true }, // Firebase Storage URL
    date: { type: Date, default: Date.now },
    tags: [String]
}, { timestamps: true });

const Report = mongoose.model('Report', reportSchema);
module.exports = Report;
