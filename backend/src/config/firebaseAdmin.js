const admin = require('firebase-admin');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config();

const serviceAccountKeyPath = path.resolve(__dirname, '../../serviceAccountKey.json');
const fs = require('fs');

try {
  // Check if service account key file exists
  let serviceAccount;

  if (fs.existsSync(serviceAccountKeyPath)) {
    serviceAccount = require(serviceAccountKeyPath);
    console.log('✅ Loaded Firebase credentials from file.');
  } else if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    try {
      serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
      console.log('✅ Loaded Firebase credentials from Environment Variable.');
    } catch (e) {
      console.error('❌ Failed to parse FIREBASE_SERVICE_ACCOUNT environment variable:', e.message);
    }
  }

  if (serviceAccount) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });

    console.log('✅ Firebase Admin SDK initialized successfully.');
  } else {
    console.warn('⚠️  Firebase Admin SDK not initialized.');
    console.warn('   - serviceAccountKey.json not found');
    console.warn('   - FIREBASE_SERVICE_ACCOUNT env var not set/valid');
    console.warn('   Server will continue with limited functionality.');
  }
} catch (error) {
  console.error('❌ Error initializing Firebase Admin SDK:', error.message);
  console.warn('   Server will continue in testing mode without Firebase.');
}

module.exports = admin;
