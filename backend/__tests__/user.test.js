
const request = require('supertest');
const app = require('../src/app');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

let mongoServer;
let token;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  const mongoUri = mongoServer.getUri();
  await mongoose.connect(mongoUri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });

  // Get a token for a test user
  await request(app)
    .post('/api/auth/send-otp')
    .send({
      phone: '1234567890',
    });

  const res = await request(app)
    .post('/api/auth/verify-otp')
    .send({
      phone: '1234567890',
      otp: '123456',
      role: 'doctor', // A doctor should have access to users and stats
      name: 'Test Doctor'
    });
  token = res.body.token;
});

afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
});

describe('User Endpoints', () => {
  it('should get all users with a valid token', async () => {
    const res = await request(app)
      .get('/api/users')
      .set('Authorization', `Bearer ${token}`);
    
    expect(res.statusCode).toEqual(200);
    expect(Array.isArray(res.body)).toBe(true);
  });
});

describe('Stats Endpoints', () => {
  it('should get stats with a valid token', async () => {
    const res = await request(app)
      .get('/api/stats')
      .set('Authorization', `Bearer ${token}`);
    
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('patients');
    expect(res.body).toHaveProperty('doctors');
    expect(res.body).toHaveProperty('reports');
    expect(res.body).toHaveProperty('active');
  });
});
