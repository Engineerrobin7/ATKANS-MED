const mongoose = require('mongoose');

const patientSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    name: { type: String, required: true },
    age: { type: Number },
    gender: { type: String, enum: ['Male', 'Female', 'Other'] },
    bloodGroup: { type: String },
    height: { type: String }, // e.g. "5'10"
    weight: { type: String }, // e.g. "75kg"
    ethnicity: { type: String },
    email: { type: String },
    address: { type: String },

    medicalInfo: {
        allergies: [String],
        conditions: [String],
        surgeries: [String],
        familyHistory: [String]
    },

    insurance: {
        provider: String,
        policyNumber: String,
        expiryDate: Date
    },

    // Authorized doctors for this patient
    authorizedDoctors: [{
        doctor: { type: mongoose.Schema.Types.ObjectId, ref: 'Doctor' },
        grantedAt: { type: Date, default: Date.now },
        accessLevel: { type: String, enum: ['read', 'write'], default: 'write' }
    }]
}, { timestamps: true });

const Patient = mongoose.model('Patient', patientSchema);
module.exports = Patient;
