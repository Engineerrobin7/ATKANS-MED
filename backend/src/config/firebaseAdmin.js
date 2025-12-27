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
    console.log('✅ Loaded Firebase credentials from serviceAccountKey.json');
  } else if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    try {
      let envValue = process.env.FIREBASE_SERVICE_ACCOUNT.trim();

      // Fix: If the value accidentally includes the variable name (confirmed from logs!)
      if (envValue.startsWith('FIREBASE_SERVICE_ACCOUNT=')) {
        envValue = envValue.replace('FIREBASE_SERVICE_ACCOUNT=', '').trim();
      }

      // If it starts and ends with quotes, remove them
      if (envValue.startsWith('"') && envValue.endsWith('"')) {
        envValue = envValue.substring(1, envValue.length - 1);
      }

      // If it looks like JSON, try to parse it
      if (envValue.startsWith('{')) {
        serviceAccount = JSON.parse(envValue);
        if (serviceAccount.private_key) {
          // CRITICAL: Convert text "\n" into real newlines for Firebase
          serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, '\n');
        }
        console.log('✅ Loaded Firebase credentials from Environment Variable.');
      } else {
        // Maybe it's base64 encoded?
        try {
          const decoded = Buffer.from(envValue, 'base64').toString('utf-8');
          if (decoded.startsWith('{')) {
            serviceAccount = JSON.parse(decoded);
            console.log('✅ Loaded Firebase credentials from Environment Variable (Base64).');
          }
        } catch (e) {
          // Not base64
        }
      }
    } catch (e) {
      console.error('❌ Failed to parse FIREBASE_SERVICE_ACCOUNT environment variable:', e.message);
      console.error('   Value length:', process.env.FIREBASE_SERVICE_ACCOUNT?.length);
    }
  }

  if (serviceAccount) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });

    console.log('✅ Firebase Admin SDK initialized successfully.');
  } else {
    console.warn('⚠️  Firebase Admin SDK not initialized.');
    console.warn('   - serviceAccountKey.json not found in ' + serviceAccountKeyPath);
    console.warn('   - FIREBASE_SERVICE_ACCOUNT env var not set/valid');
    console.warn('   Server will fail on Firestore/Auth operations.');
  }
} catch (error) {
  console.error('❌ Error during Firebase Admin SDK setup:', error);
}

module.exports = admin;
