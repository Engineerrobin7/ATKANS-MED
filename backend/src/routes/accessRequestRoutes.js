const express = require('express');
const { getAccessRequests, createAccessRequest } = require('../controllers/accessRequestController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.route('/').get(protect, getAccessRequests).post(protect, createAccessRequest);

module.exports = router;
