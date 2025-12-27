const { FirestoreHelper, Collections } = require('../config/firestore');
const path = require('path');

// @desc    Upload Report
// @route   POST /api/reports
// @access  Private (Patient/Doctor)
exports.uploadReport = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: 'No file uploaded' });
        }

        const { type, title, patientId, tags } = req.body;
        let targetPatientId = patientId;

        // Logic to determine patient
        if (req.user.role === 'patient') {
            const profiles = await FirestoreHelper.findAll(Collections.PATIENTS, { userId: req.user.id });
            const p = profiles[0];
            if (!p) return res.status(404).json({ message: 'Patient profile not found' });
            targetPatientId = p.id;
        } else if (req.user.role === 'doctor') {
            if (!targetPatientId) return res.status(400).json({ message: 'Patient ID required' });
            // Check Access
            const p = await FirestoreHelper.findById(Collections.PATIENTS, targetPatientId);
            if (!p) return res.status(404).json({ message: 'Patient not found' });

            const docProfiles = await FirestoreHelper.findAll(Collections.DOCTORS, { userId: req.user.id });
            const doctor = docProfiles[0];

            const isAuthorized = p.authorizedDoctors && p.authorizedDoctors.some(d => d.doctor === doctor.id);
            if (!isAuthorized) return res.status(403).json({ message: 'Not authorized' });
        }

        // Create Report Record
        // In real prod, upload to Firebase Storage here and get URL.
        // Here we use the local path served by Express.
        const fileUrl = `/uploads/${req.file.filename}`;

        const report = await FirestoreHelper.create(Collections.REPORTS, {
            patientId: targetPatientId,
            uploadedBy: req.user.id,
            title: title || req.file.originalname,
            type,
            fileUrl,
            tags: tags ? tags.split(',') : [],
            date: new Date().toISOString()
        });

        res.json(report);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get Reports for Patient
// @route   GET /api/reports/:patientId
// @access  Private
exports.getReports = async (req, res) => {
    try {
        const { patientId } = req.params; // This matches request parameter
        // Access Check
        if (req.user.role === 'patient') {
            const profiles = await FirestoreHelper.findAll(Collections.PATIENTS, { userId: req.user.id });
            const p = profiles[0];
            if (!p || p.id !== patientId) return res.status(403).json({ message: 'Not authorized' });
        }
        // Doctor check...

        const reports = await FirestoreHelper.findAll(Collections.REPORTS, { patientId });
        // Sort descending
        reports.sort((a, b) => new Date(b.date) - new Date(a.date));

        res.json(reports);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}
