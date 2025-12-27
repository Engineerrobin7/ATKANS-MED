const dotenv = require('dotenv');
const app = require('./src/app');

dotenv.config();

// Initialize Firebase Admin SDK and Firestore
require('./src/config/firebaseAdmin');
const { getFirestore } = require('./src/config/firestore');

// Initialize Firestore
const db = getFirestore();
if (db) {
    console.log('✅ Using Firebase Firestore as database');
} else {
    console.warn('⚠️  Firestore not initialized - add serviceAccountKey.json');
    console.warn('   Server will continue with limited functionality');
}

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`\n🚀 Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
    console.log(`📍 API available at: http://localhost:${PORT}`);
    console.log(`💾 Database: Firebase Firestore\n`);
});
