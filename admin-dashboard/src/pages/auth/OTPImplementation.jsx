// src/pages/auth/OTPScreen.jsx
import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './OTPScreen.css';

const OTPScreen = ({ email, method = 'email', isLogin = false, onSuccess }) => {
  const [otp, setOtp] = useState('');
  const [name, setName] = useState('');
  const [loading, setLoading] = useState(false);
  const [timeLeft, setTimeLeft] = useState(600); // 10 minutes
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  useEffect(() => {
    const timer = setInterval(() => {
      setTimeLeft((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const handleVerifyOTP = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (otp.length !== 6) {
      setError('Please enter a valid 6-digit OTP');
      return;
    }

    if (!isLogin && !name.trim()) {
      setError('Please enter your name');
      return;
    }

    setLoading(true);

    try {
      const endpoint = isLogin
        ? '/api/auth/verify-login-otp'
        : '/api/auth/verify-otp';

      const response = await axios.post(
        `${process.env.REACT_APP_API_URL}${endpoint}`,
        {
          email,
          otp,
          ...(isLogin ? {} : { name }),
          method,
        }
      );

      setSuccess(response.data.message);

      // Save token
      localStorage.setItem('token', response.data.token);

      // Call success callback
      if (onSuccess) {
        onSuccess(response.data);
      }

      // Redirect after 2 seconds
      setTimeout(() => {
        window.location.href = '/dashboard';
      }, 2000);
    } catch (err) {
      setError(
        err.response?.data?.message ||
        'Failed to verify OTP. Please try again.'
      );
    } finally {
      setLoading(false);
    }
  };

  const handleResendOTP = async () => {
    setError('');
    setSuccess('');

    try {
      const endpoint = isLogin
        ? '/api/auth/request-login-otp'
        : '/api/auth/send-otp';

      await axios.post(
        `${process.env.REACT_APP_API_URL}${endpoint}`,
        {
          email,
          method,
        }
      );

      setOtp('');
      setTimeLeft(600);
      setSuccess('OTP resent successfully. Check your email.');
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to resend OTP');
    }
  };

  return (
    <div className="otp-container">
      <div className="otp-card">
        <div className="otp-header">
          <h2>{isLogin ? 'Login with OTP' : 'Verify Your Email'}</h2>
          <p>We sent a 6-digit code to <strong>{email}</strong></p>
        </div>

        <form onSubmit={handleVerifyOTP} className="otp-form">
          {/* OTP Input */}
          <div className="form-group">
            <label>Enter Verification Code</label>
            <input
              type="text"
              inputMode="numeric"
              maxLength="6"
              value={otp}
              onChange={(e) => setOtp(e.target.value.replace(/\D/g, ''))}
              placeholder="000000"
              className="otp-input"
              disabled={loading}
            />
          </div>

          {/* Name Input (for registration) */}
          {!isLogin && (
            <div className="form-group">
              <label>Full Name</label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="John Doe"
                disabled={loading}
              />
            </div>
          )}

          {/* Error Message */}
          {error && <div className="alert alert-error">{error}</div>}

          {/* Success Message */}
          {success && <div className="alert alert-success">{success}</div>}

          {/* Timer and Resend */}
          <div className="otp-footer">
            <span className="timer">
              {timeLeft > 0 ? (
                <>Expires in: <strong>{formatTime(timeLeft)}</strong></>
              ) : (
                'OTP Expired'
              )}
            </span>
            <button
              type="button"
              onClick={handleResendOTP}
              disabled={timeLeft > 0 || loading}
              className="resend-btn"
            >
              Resend OTP
            </button>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            disabled={loading || otp.length !== 6}
            className="submit-btn"
          >
            {loading ? 'Verifying...' : 'Verify & Continue'}
          </button>
        </form>

        <p className="help-text">
          Didn't receive the code? Check your spam folder or request a new OTP.
        </p>
      </div>
    </div>
  );
};

export const OTPScreenComponent = OTPScreen;

// ============================================
// src/pages/auth/LoginPage.jsx
// ============================================

const LoginPage = () => {
  const [email, setEmail] = useState('');
  const [step, setStep] = useState(1); // 1: email input, 2: OTP verification
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleRequestOTP = async (e) => {
    e.preventDefault();
    setError('');

    if (!email.includes('@')) {
      setError('Please enter a valid email');
      return;
    }

    setLoading(true);

    try {
      await axios.post(
        `${process.env.REACT_APP_API_URL}/api/auth/request-login-otp`,
        {
          email,
          method: 'email',
        }
      );

      setStep(2); // Move to OTP verification
    } catch (err) {
      setError(
        err.response?.data?.message ||
        'Failed to send OTP. Please try again.'
      );
    } finally {
      setLoading(false);
    }
  };

  if (step === 2) {
    return (
      <OTPScreen
        email={email}
        method="email"
        isLogin={true}
        onSuccess={() => {
          // Handle successful login
        }}
      />
    );
  }

  return (
    <div className="login-container">
      <div className="login-card">
        <div className="login-header">
          <h1>Welcome to ATKANS MED</h1>
          <p>Login to your account</p>
        </div>

        <form onSubmit={handleRequestOTP} className="login-form">
          <div className="form-group">
            <label>Email Address</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@example.com"
              disabled={loading}
              required
            />
          </div>

          {error && <div className="alert alert-error">{error}</div>}

          <button
            type="submit"
            disabled={loading || !email}
            className="submit-btn"
          >
            {loading ? 'Sending OTP...' : 'Send Login OTP'}
          </button>
        </form>

        <div className="login-footer">
          <p>
            Don't have an account?{' '}
            <a href="/register">Sign up here</a>
          </p>
        </div>
      </div>
    </div>
  );
};

export const LoginPageComponent = LoginPage;

// ============================================
// src/pages/auth/RegisterPage.jsx
// ============================================

const RegisterPage = () => {
  const [email, setEmail] = useState('');
  const [role, setRole] = useState('patient');
  const [step, setStep] = useState(1); // 1: email input, 2: OTP verification
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSendOTP = async (e) => {
    e.preventDefault();
    setError('');

    if (!email.includes('@')) {
      setError('Please enter a valid email');
      return;
    }

    setLoading(true);

    try {
      await axios.post(
        `${process.env.REACT_APP_API_URL}/api/auth/send-otp`,
        {
          email,
          role,
          method: 'email',
        }
      );

      setStep(2); // Move to OTP verification
    } catch (err) {
      setError(
        err.response?.data?.message ||
        'Failed to send OTP. Please try again.'
      );
    } finally {
      setLoading(false);
    }
  };

  if (step === 2) {
    return (
      <OTPScreen
        email={email}
        method="email"
        isLogin={false}
        onSuccess={() => {
          // Handle successful registration
        }}
      />
    );
  }

  return (
    <div className="register-container">
      <div className="register-card">
        <div className="register-header">
          <h1>Create Account</h1>
          <p>Join ATKANS MED today</p>
        </div>

        <form onSubmit={handleSendOTP} className="register-form">
          <div className="form-group">
            <label>Email Address</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@example.com"
              disabled={loading}
              required
            />
          </div>

          <div className="form-group">
            <label>Role</label>
            <select
              value={role}
              onChange={(e) => setRole(e.target.value)}
              disabled={loading}
            >
              <option value="patient">Patient</option>
              <option value="doctor">Doctor</option>
            </select>
          </div>

          {error && <div className="alert alert-error">{error}</div>}

          <button
            type="submit"
            disabled={loading || !email}
            className="submit-btn"
          >
            {loading ? 'Sending OTP...' : 'Send OTP'}
          </button>
        </form>

        <div className="register-footer">
          <p>
            Already have an account?{' '}
            <a href="/login">Login here</a>
          </p>
        </div>
      </div>
    </div>
  );
};

export const RegisterPageComponent = RegisterPage;

// ============================================
// src/pages/auth/OTPScreen.css
// ============================================

/*
.otp-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.otp-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  padding: 40px;
  max-width: 400px;
  width: 100%;
}

.otp-header {
  text-align: center;
  margin-bottom: 30px;
}

.otp-header h2 {
  color: #333;
  margin: 0 0 10px 0;
  font-size: 24px;
}

.otp-header p {
  color: #666;
  margin: 0;
  font-size: 14px;
}

.otp-header p strong {
  color: #333;
}

.otp-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  color: #333;
  font-weight: 600;
  font-size: 14px;
}

.form-group input,
.form-group select {
  padding: 12px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  font-size: 14px;
  transition: all 0.3s ease;
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.otp-input {
  font-size: 32px !important;
  letter-spacing: 8px;
  text-align: center;
  font-weight: bold;
  font-family: 'Courier New', monospace;
}

.alert {
  padding: 12px;
  border-radius: 8px;
  font-size: 14px;
  text-align: center;
}

.alert-error {
  background-color: #ffebee;
  color: #c62828;
  border: 1px solid #ef5350;
}

.alert-success {
  background-color: #e8f5e9;
  color: #2e7d32;
  border: 1px solid #66bb6a;
}

.otp-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
  color: #666;
  padding: 15px;
  background-color: #f5f5f5;
  border-radius: 8px;
}

.timer {
  font-weight: 600;
}

.timer strong {
  color: #667eea;
}

.resend-btn {
  background: none;
  border: none;
  color: #667eea;
  cursor: pointer;
  font-size: 14px;
  font-weight: 600;
  text-decoration: underline;
}

.resend-btn:disabled {
  color: #ccc;
  cursor: not-allowed;
  text-decoration: none;
}

.submit-btn {
  padding: 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s ease;
}

.submit-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
}

.submit-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.help-text {
  text-align: center;
  color: #999;
  font-size: 12px;
  margin-top: 20px;
}
*/

// ============================================
// Main Export - Use as needed
// ============================================
// To use individual components:
// import { OTPScreenComponent as OTPScreen, LoginPageComponent as LoginPage, RegisterPageComponent as RegisterPage } from './OTPImplementation';

// Or use the combined default export:
// export { OTPScreenComponent, LoginPageComponent, RegisterPageComponent };

export default {
  OTPScreen,
  LoginPage,
  RegisterPage,
};