const express = require('express');
const router = express.Router();

router.get('/', (req, res) => res.json({ message: 'Subscription module is active' }));
const subscriptionController = require('../controllers/subscriptionController');

router.post('/create', subscriptionController.createSubscription);
router.post('/webhook', subscriptionController.handleWebhook);

module.exports = router;
