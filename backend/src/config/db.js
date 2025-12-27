const mongoose = require('mongoose');

const connectDB = async () => {
    try {
        const conn = await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/atkans-med', {
            serverSelectionTimeoutMS: 5000, // Timeout after 5s instead of 30s
        });
        console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    } catch (error) {
        console.error(`❌ MongoDB Connection Error: ${error.message}`);
        console.warn('⚠️  Server will continue without database connection.');
        console.warn('   API endpoints requiring database will return errors.');
        console.warn('   Please start MongoDB to enable full functionality.');
        console.warn('   MongoDB URI: ' + (process.env.MONGO_URI || 'mongodb://localhost:27017/atkans-med'));
    }
};

module.exports = connectDB;
