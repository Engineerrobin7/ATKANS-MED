const { FirestoreHelper, Collections } = require('../config/firestore');

// @desc    Get all access requests
// @route   GET /api/access-requests
// @access  Private
exports.getAccessRequests = async (req, res) => {
    try {
        let accessRequests = await FirestoreHelper.findAll(Collections.ACCESS_REQUESTS);

        // Optionally filter by user role
        if (req.user.role === 'doctor') {
            accessRequests = accessRequests.filter(ar => ar.doctorId === req.user.id);
        } else if (req.user.role === 'patient') {
            accessRequests = accessRequests.filter(ar => ar.patientId === req.user.id);
        }

        res.status(200).json(accessRequests);
    } catch (error) {
        console.error('Get access requests error:', error);
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create an access request
// @route   POST /api/access-requests
// @access  Private
exports.createAccessRequest = async (req, res) => {
    const { doctorId, patientId, reason, duration } = req.body;

    try {
        const accessRequest = await FirestoreHelper.create(Collections.ACCESS_REQUESTS, {
            doctorId: doctorId || req.user.id,
            patientId,
            reason: reason || 'Medical consultation',
            duration: duration || 24, // hours
            status: 'pending',
            requestedAt: new Date().toISOString()
        });

        res.status(201).json(accessRequest);
    } catch (error) {
        console.error('Create access request error:', error);
        res.status(500).json({ message: error.message });
    }
};
