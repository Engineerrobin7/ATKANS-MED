# How to Deploy ATKANS MED Backend to Render (Free)

This guide will help you deploy your backend server to Render so your app works 24/7.

## Step 1: Upload Backend to GitHub
1. Create a **New Repository** on GitHub (e.g., `atkans-med-backend`).
2. Open a terminal in your project root (`ATKANS MED`) and run:
   ```bash
   git init
   git add backend
   git commit -m "Initial commit for backend"
   git branch -M main
   # Replace URL below with your actual GitHub repo URL
   git remote add origin https://github.com/YOUR_USERNAME/atkans-med-backend.git
   git push -u origin main
   ```
   *(If you already have a repo, just make sure the `backend` folder is pushed).*

## Step 2: Create a Web Service on Render
1. Go to [dashboard.render.com](https://dashboard.render.com) and Sign Up/Log In.
2. Click **New +** -> **Web Service**.
3. Select **"Build and deploy from a Git repository"**.
4. Connect your GitHub account and select your `atkans-med-backend` repository.

## Step 3: Configure Render
Fill in the details:
*   **Name**: `atkans-med-api` (or similar)
*   **Region**: Singapore (or nearest to you)
*   **Branch**: `main`
*   **Root Directory**: `backend` (Important! because your package.json is inside backend folder)
*   **Runtime**: Node
*   **Build Command**: `npm install`
*   **Start Command**: `node server.js`
*   **Instance Type**: Free

## Step 4: Environment Variables (Secrets)
Scroll down to **Environment Variables** and add the following keys from your `.env` file:

| Key | Value |
| :--- | :--- |
| `NODE_ENV` | `production` |
| `PORT` | `3000` (Render handles port, but good to set) |
| `JWT_SECRET` | *[Copy from your .env]* |
| `EMAIL_USER` | *[Copy from your .env]* |
| `EMAIL_PASS` | *[Copy from your .env]* |
| `TWILIO_ACCOUNT_SID` | *[Copy from your .env]* |
| `TWILIO_AUTH_TOKEN` | *[Copy from your .env]* |
| `TWILIO_PHONE_NUMBER` | *[Copy from your .env]* |
| `RAZORPAY_KEY_ID` | *[Copy from your .env]* |
| `RAZORPAY_KEY_SECRET` | *[Copy from your .env]* |

### **Vital: The Firebase Key**
1. Open your `backend/serviceAccountKey.json` file.
2. Copy the **entire content** (starts with `{` and ends with `}`).
3. In Render Environment Variables, add a new key:
    *   **Key**: `FIREBASE_SERVICE_ACCOUNT`
    *   **Value**: *[Paste the JSON content here]*

## Step 5: Deploy
1. Click **Create Web Service**.
2. Render will start building your app. It takes about 2-3 minutes.
3. Once done, you will see a green **"Live"** badge.
4. Copy your new **Service URL** (e.g., `https://atkans-med-api.onrender.com`).

## Step 6: Connect App to Cloud
1. Open `mobile/lib/core/constants/api_constants.dart`.
2. Change the `baseUrl`:
   ```dart
   // Old
   // static const String baseUrl = 'http://10.0.2.2:5000/api'; 
   
   // New
   static const String baseUrl = 'https://atkans-med-api.onrender.com/api';
   ```
3. Rebuild your app (`flutter run` or `flutter build apk`).

**🎉 Done! Your app is now online 24/7.**
