const mongoose = require('mongoose');

const prescriptionSchema = new mongoose.Schema({
    patient: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Patient',
        required: true
    },
    doctor: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Doctor',
        required: true
    },
    date: {
        type: Date,
        default: Date.now
    },
    medicines: [{
        name: { type: String, required: true },
        dosage: { type: String, required: true },
        frequency: { type: String }, // e.g. "1-0-1"
        duration: { type: String }, // e.g. "5 days"
        instructions: { type: String } // e.g. "After food"
    }],
    notes: { type: String },
    isLocked: {
        type: Boolean,
        default: false // Admin can lock
    }
}, { timestamps: true });

const Prescription = mongoose.model('Prescription', prescriptionSchema);
module.exports = Prescription;
