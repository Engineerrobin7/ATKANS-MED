const express = require('express');
const router = express.Router();

router.get('/', (req, res) => res.json({ message: 'Reports module is active' }));
const multer = require('multer');
const path = require('path');
const { uploadReport, getReports } = require('../controllers/reportController');
const { protect } = require('../middleware/auth');

// Multer Config
const storage = multer.diskStorage({
    destination(req, file, cb) {
        cb(null, 'uploads/');
    },
    filename(req, file, cb) {
        cb(null, `${file.fieldname}-${Date.now()}${path.extname(file.originalname)}`);
    }
});

const upload = multer({
    storage,
    fileFilter: function (req, file, cb) {
        checkFileType(file, cb);
    }
});

function checkFileType(file, cb) {
    const filetypes = /jpeg|jpg|png|pdf/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = filetypes.test(file.mimetype);

    if (mimetype && extname) {
        return cb(null, true);
    } else {
        cb('Images and PDFs only!');
    }
}

router.post('/', protect, upload.single('file'), uploadReport);
router.get('/:patientId', protect, getReports);

module.exports = router;
