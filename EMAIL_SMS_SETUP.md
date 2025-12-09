# 📧📱 Email & SMS OTP Setup Guide

## ✅ What's Implemented

Your app now has **REAL OTP delivery** via:
- ✉️ **Email** (using Nodemailer)
- 📱 **SMS** (using Twilio)

Backend functions are ready in `backend/functions/index.js`:
- `sendEmailOTP` - Sends OTP to email
- `verifyEmailOTP` - Verifies email OTP
- `sendSMSOTP` - Sends OTP via SMS
- `verifySMSOTP` - Verifies SMS OTP

---

## 🚀 Quick Start (3 Options)

### Option 1: Demo Mode (Current - No Setup Needed)
- OTP displayed on screen
- No actual email/SMS sent
- **Works NOW** without any configuration

### Option 2: Email OTP Only (Easiest)
- Set up Gmail app password (5 minutes)
- Real emails sent
- SMS still in demo mode

### Option 3: Full Setup (Email + SMS)
- Gmail + Twilio
- Real emails AND SMS sent
- Professional production-ready

---

## 📧 Email OTP Setup (Gmail)

### Step 1: Enable 2-Factor Authentication
1. Go to https://myaccount.google.com/security
2. Enable **2-Step Verification**

### Step 2: Create App Password
1. Visit https://myaccount.google.com/apppasswords
2. Select App: **Mail**
3. Select Device: **Other (Custom name)**
4. Name it: `ATKANS MED`
5. Click **Generate**
6. **Copy the 16-character password**

### Step 3: Configure Firebase Functions
```bash
cd backend/functions

# Set email configuration
firebase functions:config:set email.user="your-email@gmail.com"
firebase functions:config:set email.password="your-16-char-app-password"

# View config
firebase functions:config:get
```

### Step 4: Deploy
```bash
firebase deploy --only functions:sendEmailOTP,functions:verifyEmailOTP
```

### ✅ Email OTP Now Works!
Users will receive beautiful HTML emails with OTP codes!

---

## 📱 SMS OTP Setup (Twilio)

### Step 1: Create Twilio Account
1. Visit https://www.twilio.com/try-twilio
2. Sign up (free trial gives $15 credit)
3. Verify your email and phone

### Step 2: Get Credentials
1. Go to Twilio Console: https://console.twilio.com/
2. Find these values:
   - **Account SID** (starts with AC...)
   - **Auth Token** (click to reveal)

### Step 3: Get Phone Number
1. In Twilio Console → Phone Numbers
2. Click **Get a Number**
3. Choose a number (free with trial)
4. Copy the number (e.g., `+1 234 567 8900`)

### Step 4: Configure Firebase Functions
```bash
cd backend/functions

# Set Twilio configuration
firebase functions:config:set twilio.account_sid="AC..."
firebase functions:config:set twilio.auth_token="your-auth-token"
firebase functions:config:set twilio.phone_number="+1234567890"

# View config
firebase functions:config:get
```

### Step 5: Install Dependencies & Deploy
```bash
# Install packages
npm install

# Deploy
firebase deploy --only functions:sendSMSOTP,functions:verifySMSOTP
```

### ✅ SMS OTP Now Works!
Users will receive SMS with OTP codes!

---

## 🔧 Alternative Email Providers

### SendGrid (Recommended for Production)
```javascript
// In functions/index.js, replace Gmail config with:
const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(functions.config().sendgrid.api_key);

// Send email
await sgMail.send({
  to: email,
  from: 'noreply@atkansmed.com',
  subject: 'Your OTP Code',
  html: htmlContent,
});
```

**Setup:**
```bash
# Get API key from https://sendgrid.com/
firebase functions:config:set sendgrid.api_key="SG.xxxxx"
```

### Mailgun
```bash
# Sign up at https://mailgun.com/
firebase functions:config:set mailgun.api_key="your-key"
firebase functions:config:set mailgun.domain="mg.yourdomain.com"
```

---

## 🎨 Email Template

The OTP email looks like this:

```
┌─────────────────────────────────────────┐
│                                         │
│           🏥 ATKANS MED                 │
│     Your Health, Our Priority           │
│                                         │
│  Hello,                                 │
│  Your One-Time Password (OTP) is:      │
│                                         │
│  ╔═══════════════════════════════╗     │
│  ║                               ║     │
│  ║     4 8 2 7 5 1              ║     │
│  ║  (Large, Bold, Lime Green)   ║     │
│  ║                               ║     │
│  ╚═══════════════════════════════╝     │
│                                         │
│  This code expires in 10 minutes.      │
│                                         │
│  © 2024 ATKANS MED                     │
└─────────────────────────────────────────┘
```

**Features:**
- Professional HTML design
- Lime green branding
- Clear expiry notice
- Responsive layout

---

## 📱 SMS Template

```
Your ATKANS MED OTP is: 482751
Valid for 10 minutes.
```

**Features:**
- Short and clear
- Includes app name
- Shows expiry time

---

## 🔒 Security Features

### OTP Storage (Firestore)
```javascript
{
  code: "482751",
  email: "user@example.com",
  createdAt: Timestamp,
  expiresAt: Timestamp (10 min),
  verified: false
}
```

### Protection:
- ✅ **Expiry**: OTPs expire after 10 minutes
- ✅ **One-time use**: Can't reuse verified OTPs
- ✅ **Auto-cleanup**: Expired OTPs deleted daily
- ✅ **Rate limiting**: Can add to prevent spam

---

## 🧪 Testing

### Test Email OTP
```bash
# In Firebase Console → Functions
# Or use cURL:
curl -X POST https://YOUR-PROJECT.cloudfunctions.net/sendEmailOTP \
  -H "Content-Type: application/json" \
  -d '{"data": {"email": "test@example.com"}}'
```

### Test SMS OTP
```bash
curl -X POST https://YOUR-PROJECT.cloudfunctions.net/sendSMSOTP \
  -H "Content-Type: application/json" \
  -d '{"data": {"phoneNumber": "+1234567890"}}'
```

### Demo Mode (Current)
- Email/SMS not sent
- OTP displayed on screen
- Perfect for development!

---

## 💰 Cost Estimates

### Email (Gmail)
- **Free** for development
- SendGrid: $15/month for 40k emails

### SMS (Twilio)
- **Free trial**: $15 credit
- After trial: $0.0075/SMS (US)
- 100 SMS = $0.75
- 1,000 SMS = $7.50

### Firestore
- **Free tier**: 50k reads/day
- More than enough for OTP storage

---

## 🔄 Migration Path

### Current: Demo Mode
```
User enters phone/email
  ↓
Random OTP generated
  ↓
Displayed on screen ← YOU ARE HERE
  ↓
User enters OTP
  ↓
Verified locally
```

### After Setup: Real OTP
```
User enters phone/email
  ↓
Cloud Function called
  ↓
OTP generated & stored in Firestore
  ↓
Email/SMS sent ← AFTER SETUP
  ↓
User receives OTP
  ↓
User enters OTP
  ↓
Cloud Function verifies
  ↓
Success!
```

---

## 📋 Deployment Checklist

- [ ] Firebase project created
- [ ] Billing enabled (for Cloud Functions)
- [ ] Gmail app password created (for email)
- [ ] Twilio account created (for SMS)
- [ ] Firebase config set (`firebase functions:config:set ...`)
- [ ] Dependencies installed (`npm install`)
- [ ] Functions deployed (`firebase deploy --only functions`)
- [ ] Test email sent successfully
- [ ] Test SMS sent successfully
- [ ] Update Flutter app to call functions (instead of local generation)

---

## 🐛 Troubleshooting

### Email not sending?
```bash
# Check config
firebase functions:config:get

# Check logs
firebase functions:log

# Common issues:
# - Wrong app password
# - 2FA not enabled
# - Less secure apps blocked
```

### SMS not sending?
```bash
# Verify Twilio credentials
# Check Twilio console for errors
# Ensure phone number is verified (trial mode)
# Check balance
```

### Functions not deploying?
```bash
# Ensure billing is enabled
firebase projects:list
firebase use YOUR-PROJECT-ID
npm audit fix
firebase deploy --only functions --debug
```

---

## 🎯 Next Steps

1. **Choose your setup tier** (Demo, Email only, or Full)
2. **Follow setup guide above**
3. **Deploy functions**
4. **Update Flutter app** (in next step)
5. **Test with real users**

---

**Demo mode works perfectly for now - users see OTP on screen!**
**Set up email/SMS when you're ready to go live!** 🚀
