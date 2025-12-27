
const request = require('supertest');
const app = require('../src/app');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

let mongoServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  const mongoUri = mongoServer.getUri();
  await mongoose.connect(mongoUri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
});

afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
});

describe('Auth Endpoints', () => {
  it('should send an OTP to a user', async () => {
    const res = await request(app)
      .post('/api/auth/send-otp')
      .send({
        phone: '1234567890',
      });
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('success', true);
  });

  it('should verify the OTP and return a token', async () => {
    // First, send OTP
    await request(app)
      .post('/api/auth/send-otp')
      .send({
        phone: '1234567890',
      });

    // Then, verify OTP
    const res = await request(app)
      .post('/api/auth/verify-otp')
      .send({
        phone: '1234567890',
        otp: '123456',
        role: 'patient',
        name: 'Test User'
      });
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('token');
  });

  it('should not verify an invalid OTP', async () => {
    // First, send OTP
    await request(app)
      .post('/api/auth/send-otp')
      .send({
        phone: '1234567890',
      });

    // Then, verify OTP with a wrong OTP
    const res = await request(app)
      .post('/api/auth/verify-otp')
      .send({
        phone: '1234567890',
        otp: '654321',
      });
    expect(res.statusCode).toEqual(400);
    expect(res.body).toHaveProperty('message', 'Invalid OTP');
  });

  it('should get the user profile with a valid token', async () => {
    // First, send OTP
    await request(app)
        .post('/api/auth/send-otp')
        .send({
            phone: '1234567890',
        });

    // Then, verify OTP to get a token
    const resVerify = await request(app)
        .post('/api/auth/verify-otp')
        .send({
            phone: '1234567890',
            otp: '123456',
            role: 'patient',
            name: 'Test User'
        });

    const token = resVerify.body.token;

    // Now, get the user profile
    const res = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${token}`);
    
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('user');
    expect(res.body).toHaveProperty('profile');
    });
});
