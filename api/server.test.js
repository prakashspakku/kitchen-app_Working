const request = require('supertest');

jest.mock('mongodb', () => {
  const orders = [];
  return {
    MongoClient: {
      connect: jest.fn(() =>
        Promise.resolve({
          db: () => ({
            collection: () => ({
              find: () => ({ toArray: () => Promise.resolve(orders) }),
              insertOne: (doc) => {
                const inserted = { _id: 'mocked-id', ...doc };
                orders.push(inserted);
                return Promise.resolve({ insertedId: inserted._id });
              },
            }),
          }),
        })
      ),
    },
  };
});

const app = require('./server');

beforeAll(async () => {
  await app.connectDb();
});

test('GET /health returns status and db', async () => {
  const res = await request(app).get('/health');
  expect(res.status).toBe(200);
  expect(res.body).toHaveProperty('status', 'ok');
  expect(res.body).toHaveProperty('db');
});

test('GET /metrics returns Prometheus format with http_requests_total', async () => {
  const res = await request(app).get('/metrics');
  expect(res.status).toBe(200);
  expect(res.headers['content-type']).toMatch(/text\/plain/);
  expect(res.text).toMatch(/http_requests_total/);
});

test('GET /metrics includes kitchen_orders_created_total', async () => {
  const res = await request(app).get('/metrics');
  expect(res.text).toMatch(/kitchen_orders_created_total/);
});

test('POST /orders creates order and returns 201', async () => {
  const res = await request(app)
    .post('/orders')
    .set('Content-Type', 'application/json')
    .send({ dish: 'Test Dish' });
  expect(res.status).toBe(201);
  expect(res.body).toHaveProperty('dish', 'Test Dish');
  expect(res.body).toHaveProperty('status', 'pending');
});

test('GET /orders returns array', async () => {
  const res = await request(app).get('/orders');
  expect(res.status).toBe(200);
  expect(Array.isArray(res.body)).toBe(true);
});
