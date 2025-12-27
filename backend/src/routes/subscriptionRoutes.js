const express = require('express');
const router = express.Router();
const subscriptionController = require('../controllers/subscriptionController');

router.post('/create', subscriptionController.createSubscription);
router.post('/webhook', subscriptionController.handleWebhook);

module.exports = router;
