const express = require('express');
const router = express.Router();
const { requestAccess, addPrescription, getPrescriptions } = require('../controllers/doctorController');
const { protect, authorize } = require('../middleware/auth');

router.post('/request-access', protect, authorize('doctor'), requestAccess);
router.post('/prescription', protect, authorize('doctor'), addPrescription);
router.get('/prescriptions/:patientId', protect, getPrescriptions);

module.exports = router;
