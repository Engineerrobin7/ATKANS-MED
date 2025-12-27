const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  email: { // Added email field
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true,
    match: [/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/, 'Please fill a valid email address']
  },
  phone: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  role: {
    type: String,
    enum: ['patient', 'doctor', 'admin'],
    default: 'patient'
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  otp: { // Added OTP field
    type: String
  },
  otpExpires: { // Added OTP expiration field
    type: Date
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.models.User || mongoose.model('User', userSchema);
