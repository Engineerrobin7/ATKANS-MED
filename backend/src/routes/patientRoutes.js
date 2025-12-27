const express = require('express');
const router = express.Router();
const { getPatientProfile, updateProfile, revokeAccess, respondToAccessRequest, getAccessRequests } = require('../controllers/patientController');
const { protect } = require('../middleware/auth');

router.get('/access-requests', protect, getAccessRequests);
router.get('/:id', protect, getPatientProfile);
router.put('/profile', protect, updateProfile);
router.post('/revoke-access', protect, revokeAccess);
router.post('/respond-access', protect, respondToAccessRequest);

module.exports = router;
