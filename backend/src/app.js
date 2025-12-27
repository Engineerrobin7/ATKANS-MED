const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');

// Routes
const authRoutes = require('./routes/authRoutes');
const patientRoutes = require('./routes/patientRoutes');
const doctorRoutes = require('./routes/doctorRoutes');
const reportRoutes = require('./routes/reportRoutes');
const subscriptionRoutes = require('./routes/subscriptionRoutes');
const accessRequestRoutes = require('./routes/accessRequestRoutes');
const userRoutes = require('./routes/userRoutes');
const statsRoutes = require('./routes/statsRoutes');

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Static Folder
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Route Mounting
app.use('/api/auth', authRoutes);
app.use('/api/patient', patientRoutes);
app.use('/api/doctor', doctorRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/subscription', subscriptionRoutes);
app.use('/api/access-requests', accessRequestRoutes);
app.use('/api/users', userRoutes);
app.use('/api/stats', statsRoutes);

app.get('/', (req, res) => {
    res.send('Atkans Med API is running...');
});

// Error Handling
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        message: err.message,
        stack: process.env.NODE_ENV === 'production' ? null : err.stack,
    });
});

module.exports = app;
