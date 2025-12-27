const { FirestoreHelper, Collections } = require('../config/firestore');

// @desc    Get Patient Profile
// @route   GET /api/patient/:id
// @access  Private (Patient/Doctor/Admin)
exports.getPatientProfile = async (req, res) => {
    try {
        // req.params.id here implies userId because route is usually /:id or /me
        const profiles = await FirestoreHelper.findAll(Collections.PATIENTS, { userId: req.params.id });
        const patient = profiles[0];

        if (!patient) return res.status(404).json({ message: 'Patient not found' });

        // Retrieve User data manual population
        const user = await FirestoreHelper.findById(Collections.USERS, patient.userId);
        patient.user = user ? { id: user.id, phone: user.phone, isVerified: user.isVerified, role: user.role } : null;

        // Permission Check
        if (req.user.role === 'patient' && req.user.id !== patient.userId) {
            return res.status(403).json({ message: 'Not authorized' });
        }

        if (req.user.role === 'doctor') {
            const docProfiles = await FirestoreHelper.findAll(Collections.DOCTORS, { userId: req.user.id });
            const doctor = docProfiles[0];

            if (doctor) {
                const isAuthorized = patient.authorizedDoctors && patient.authorizedDoctors.some(
                    doc => doc.doctor === doctor.id
                );
                if (!isAuthorized) {
                    return res.status(403).json({ message: 'Access denied. Request access first.' });
                }
            }
        }

        res.json(patient);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update Patient Profile
// @route   PUT /api/patient/profile
// @access  Private (Patient/Admin)
exports.updateProfile = async (req, res) => {
    try {
        const { name, height, weight, medicalInfo, insurance, age, gender } = req.body;

        // Find profile associated with logged in user
        const profiles = await FirestoreHelper.findAll(Collections.PATIENTS, { userId: req.user.id });
        let patient = profiles[0];

        if (!patient) {
            // Create if not exists
            patient = await FirestoreHelper.create(Collections.PATIENTS, {
                userId: req.user.id,
                name,
                authorizedDoctors: [],
                createdAt: new Date().toISOString()
            });
        }

        const updates = {};
        if (name) updates.name = name;
        if (height) updates.height = height;
        if (weight) updates.weight = weight;
        if (age) updates.age = age;
        if (gender) updates.gender = gender;

        if (medicalInfo) {
            updates.medicalInfo = patient.medicalInfo || {};
            if (medicalInfo.allergies) updates.medicalInfo.allergies = medicalInfo.allergies;
            if (medicalInfo.conditions) updates.medicalInfo.conditions = medicalInfo.conditions;
        }

        if (insurance) updates.insurance = insurance;

        const updatedPatient = await FirestoreHelper.updateById(Collections.PATIENTS, patient.id, updates);
        res.json(updatedPatient);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Revoke Doctor Access
// @route   POST /api/patient/revoke-access
// @access  Private (Patient)
exports.revokeAccess = async (req, res) => {
    const { doctorId } = req.body;

    try {
        const profiles = await FirestoreHelper.findAll(Collections.PATIENTS, { userId: req.user.id });
        const patient = profiles[0];
        if (!patient) return res.status(404).json({ message: 'Patient profile not found' });

        const newAuthorized = patient.authorizedDoctors ? patient.authorizedDoctors.filter(
            doc => doc.doctor !== doctorId
        ) : [];

        await FirestoreHelper.updateById(Collections.PATIENTS, patient.id, { authorizedDoctors: newAuthorized });

        res.json({ message: 'Access revoked', authorizedDoctors: newAuthorized });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Respond to Access Request
// @route   POST /api/patient/respond-access
// @access  Private (Patient)
exports.respondToAccessRequest = async (req, res) => {
    const { requestId, status } = req.body; // status: 'approved' or 'rejected'

    try {
        const request = await FirestoreHelper.findById(Collections.ACCESS_REQUESTS, requestId);
        if (!request) return res.status(404).json({ message: 'Request not found' });

        // Verify patient owns this request
        const profiles = await FirestoreHelper.findAll(Collections.PATIENTS, { userId: req.user.id });
        const patient = profiles[0];

        // logic: request could have patientId (profile ID) OR patientPhone
        const matchesProfile = request.patientId === patient.id;
        const matchesPhone = request.patientPhone === req.user.phone;

        if (!matchesPhone && !matchesProfile) {
            return res.status(403).json({ message: 'Not authorized to respond to this request' });
        }

        await FirestoreHelper.updateById(Collections.ACCESS_REQUESTS, requestId, {
            status,
            responseDate: new Date().toISOString()
        });

        if (status === 'approved') {
            // Add to authorizedDoctors
            const currentAuth = patient.authorizedDoctors || [];
            const exists = currentAuth.some(d => d.doctor === request.doctorId);
            if (!exists) {
                currentAuth.push({
                    doctor: request.doctorId,
                    grantedAt: new Date().toISOString(),
                    accessLevel: 'write'
                });
                await FirestoreHelper.updateById(Collections.PATIENTS, patient.id, { authorizedDoctors: currentAuth });
            }
        }

        res.json({ message: `Request ${status}`, request });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}

// @desc    Get Pending Requests
// @route   GET /api/patient/access-requests
// @access  Private (Patient)
exports.getAccessRequests = async (req, res) => {
    try {
        const profiles = await FirestoreHelper.findAll(Collections.PATIENTS, { userId: req.user.id });
        const patient = profiles[0];

        // Firestore helper findAll only does strict equality on one field usually or simple filters
        // Complex OR query needs manual handling or raw firestore
        // We will fetch all pending and filter in memory for now (MVP)
        // Ideally: use 'status' filter then check patient
        const allPending = await FirestoreHelper.findAll(Collections.ACCESS_REQUESTS, { status: 'pending' });

        const myRequests = allPending.filter(req =>
            req.patientPhone === req.user.phone || (patient && req.patientId === patient.id)
        );

        // Populate doctor details manually
        const populatedRequests = await Promise.all(myRequests.map(async (request) => {
            const docProfile = await FirestoreHelper.findById(Collections.DOCTORS, request.doctorId); // request.doctorId should be doctor PROFILE id? Or userId? controller says doctorId
            // doctorController creates request with 'doctor: doctor._id' which is Profile ID.

            return {
                ...request,
                doctor: docProfile ? { name: docProfile.name, specialty: docProfile.specialty, hospital: docProfile.hospital } : null
            };
        }));

        res.json(populatedRequests);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}
