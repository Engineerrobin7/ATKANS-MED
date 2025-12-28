const express = require('express');
const { getStats } = require('../controllers/statsController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/', (req, res) => res.json({ message: 'Stats module is active' }));

router.get('/', protect, getStats);

module.exports = router;
