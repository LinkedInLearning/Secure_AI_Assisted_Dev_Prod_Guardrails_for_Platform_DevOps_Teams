import request from 'supertest';
import app from '../index';

describe('Sensor API', () => {
  describe('GET /health', () => {
    it('should return healthy status', async () => {
      const response = await request(app).get('/health');
      expect(response.status).toBe(200);
      expect(response.body.status).toBe('healthy');
      expect(response.body.service).toBe('sensor-api');
    });
  });

  describe('GET /api/sensors', () => {
    it('should return list of sensors', async () => {
      const response = await request(app).get('/api/sensors');
      expect(response.status).toBe(200);
      expect(response.body.sensors).toHaveLength(3);
      expect(response.body.sensors[0]).toHaveProperty('id');
      expect(response.body.sensors[0]).toHaveProperty('type');
    });
  });

  describe('POST /api/sensors/:id/readings', () => {
    it('should accept sensor reading', async () => {
      const response = await request(app)
        .post('/api/sensors/sensor-001/readings')
        .send({ value: 45.2 });

      expect(response.status).toBe(201);
      expect(response.body.sensorId).toBe('sensor-001');
      expect(response.body.value).toBe(45.2);
    });

    it('should reject reading without value', async () => {
      const response = await request(app).post('/api/sensors/sensor-001/readings').send({});

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Reading value is required');
    });
  });
});
