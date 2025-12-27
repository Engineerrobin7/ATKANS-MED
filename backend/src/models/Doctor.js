const mongoose = require('mongoose');

const doctorSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    name: { type: String, required: true },
    specialty: { type: String, required: true },
    hospital: { type: String },
    experienceYears: { type: Number },
    licenseNumber: { type: String },

    type: {
        type: String,
        enum: ['approved', 'verified'], // Type 1: Approved, Type 2: Verified (Atkans House)
        default: 'approved'
    },

    isAtkansVerified: {
        type: Boolean,
        default: false
    }
}, { timestamps: true });

const Doctor = mongoose.model('Doctor', doctorSchema);
module.exports = Doctor;
