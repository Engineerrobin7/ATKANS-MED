const admin = require('firebase-admin');
const dotenv = require('dotenv');
const path = require('path');
const fs = require('fs');

dotenv.config();

const serviceAccountKeyPath = path.resolve(__dirname, '../../serviceAccountKey.json');

const initializeFirebase = () => {
  try {
    if (admin.apps.length > 0) {
      return admin.app();
    }

    let serviceAccount = null;

    // 1. Try Loading from file
    if (fs.existsSync(serviceAccountKeyPath)) {
      serviceAccount = require(serviceAccountKeyPath);
      console.log('✅ Firebase: Using credentials from serviceAccountKey.json');
    }
    // 2. Try Loading from Environment Variable
    else if (process.env.FIREBASE_SERVICE_ACCOUNT) {
      try {
        let envValue = process.env.FIREBASE_SERVICE_ACCOUNT.trim();

        // Clean up any prefix or quotes
        if (envValue.startsWith('FIREBASE_SERVICE_ACCOUNT=')) {
          envValue = envValue.replace('FIREBASE_SERVICE_ACCOUNT=', '').trim();
        }
        if (envValue.startsWith('"') && envValue.endsWith('"')) {
          envValue = envValue.substring(1, envValue.length - 1);
        }

        if (envValue.startsWith('{')) {
          serviceAccount = JSON.parse(envValue);
        } else {
          // Try decoding base64 if it's not raw JSON
          const decoded = Buffer.from(envValue, 'base64').toString('utf-8');
          if (decoded.startsWith('{')) {
            serviceAccount = JSON.parse(decoded);
          }
        }

        if (serviceAccount && serviceAccount.private_key) {
          serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, '\n');
          console.log('✅ Firebase: Using credentials from Environment Variable');
        }
      } catch (err) {
        console.error('❌ Firebase: Error parsing Service Account JSON:', err.message);
      }
    }

    if (!serviceAccount) {
      console.warn('⚠️  Firebase Admin SDK NOT initialized: No valid credentials found.');
      return null;
    }

    return admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: serviceAccount.project_id
    });
  } catch (error) {
    console.error('❌ Firebase: Generic initialization error:', error.message);
    return null;
  }
};

const firebaseApp = initializeFirebase();

if (firebaseApp) {
  console.log('🚀 Firebase Admin SDK initialized for project:', firebaseApp.options.projectId);
}

module.exports = admin;
