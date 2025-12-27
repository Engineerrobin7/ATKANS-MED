const { FirestoreHelper, Collections } = require('../config/firestore');

// @desc    Request Access to Patient
// @route   POST /api/doctor/request-access
// @access  Private (Doctor)
exports.requestAccess = async (req, res) => {
    const { patientPhone } = req.body;

    try {
        const docProfiles = await FirestoreHelper.findAll(Collections.DOCTORS, { userId: req.user.id });
        const doctor = docProfiles[0];
        if (!doctor) return res.status(404).json({ message: 'Doctor profile not found' });

        // Check if patient exists in system
        const users = await FirestoreHelper.findAll(Collections.USERS, { phone: patientPhone, role: 'patient' });
        const patientUser = users[0];
        let patientId = null;

        if (patientUser) {
            const pProfiles = await FirestoreHelper.findAll(Collections.PATIENTS, { userId: patientUser.id });
            if (pProfiles.length > 0) patientId = pProfiles[0].id; // Storing Profile ID
        }

        const request = await FirestoreHelper.create(Collections.ACCESS_REQUESTS, {
            doctorId: doctor.id, // Store Profile ID
            patientPhone,
            patientId, // Can be null
            status: 'pending',
            requestedAt: new Date().toISOString()
        });

        res.json(request);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Add Prescription
// @route   POST /api/doctor/prescription
// @access  Private (Doctor)
exports.addPrescription = async (req, res) => {
    const { patientId, medicines, notes } = req.body; // patientId refers to Patient Profile ID

    try {
        const docProfiles = await FirestoreHelper.findAll(Collections.DOCTORS, { userId: req.user.id });
        const doctor = docProfiles[0];

        const patient = await FirestoreHelper.findById(Collections.PATIENTS, patientId);
        if (!patient) return res.status(404).json({ message: 'Patient not found' });

        // Check Access
        const isAuthorized = patient.authorizedDoctors && patient.authorizedDoctors.some(
            doc => doc.doctor === doctor.id
        );

        // Admin override or Doctor access
        if (!isAuthorized && req.user.role !== 'admin') {
            return res.status(403).json({ message: 'Access denied. You are not authorized to write for this patient.' });
        }

        const prescription = await FirestoreHelper.create(Collections.PRESCRIPTIONS, {
            patientId: patientId,
            doctorId: doctor.id,
            medicines,
            notes,
            date: new Date().toISOString()
        });

        res.json(prescription);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get All Prescriptions for a Patient
// @route   GET /api/doctor/prescriptions/:patientId
// @access  Private
exports.getPrescriptions = async (req, res) => {
    try {
        const { patientId } = req.params;
        // Access Check (Patient reading own, or Doctor reading authorized)
        if (req.user.role === 'patient') {
            const pProfiles = await FirestoreHelper.findAll(Collections.PATIENTS, { userId: req.user.id });
            const p = pProfiles[0];
            // Verify patientId matches own profile id
            if (!p || p.id !== patientId) return res.status(403).json({ message: 'Not authorized' });
        }

        // If doctor, check auth... (omitted based on original, but good to have)

        const prescriptions = await FirestoreHelper.findAll(Collections.PRESCRIPTIONS, { patientId });

        // Manual Populate Doctor
        const populated = await Promise.all(prescriptions.map(async (presc) => {
            const doc = await FirestoreHelper.findById(Collections.DOCTORS, presc.doctorId);
            return {
                ...presc,
                doctor: doc ? { name: doc.name, specialty: doc.specialty, hospital: doc.hospital } : null
            };
        }));

        // Sort descending (in memory for now)
        populated.sort((a, b) => new Date(b.date) - new Date(a.date));

        res.json(populated);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}
