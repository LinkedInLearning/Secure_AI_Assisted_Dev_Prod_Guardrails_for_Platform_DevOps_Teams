import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { Pool } from 'pg';
import { createClient } from 'redis';
import * as tf from '@tensorflow/tfjs-node';
import winston from 'winston';

const app = express();
const port = process.env.PORT || 8080;

// Logging
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'app.log' })
  ]
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});
app.use(limiter);

// Database connection
const db = new Pool({
  connectionString: process.env.DATABASE_URL
});

// Redis cache
const redis = createClient({
  url: process.env.REDIS_URL
});
redis.connect();

// ML model (loaded at startup)
let model: tf.LayersModel;

async function loadModel() {
  model = await tf.loadLayersModel('file://./models/yield-predictor/model.json');
  logger.info('ML model loaded successfully');
}

// Health endpoints
app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.get('/ready', async (req, res) => {
  try {
    await db.query('SELECT 1');
    await redis.ping();
    res.json({ status: 'ready' });
  } catch (error) {
    res.status(503).json({ status: 'not ready', error: error.message });
  }
});

// Prediction endpoint
app.post('/predict', async (req, res) => {
  try {
    const { fieldId, sensorData } = req.body;

    // Check cache
    const cacheKey = `prediction:${fieldId}:${JSON.stringify(sensorData)}`;
    const cached = await redis.get(cacheKey);
    if (cached) {
      return res.json(JSON.parse(cached));
    }

    // Prepare input tensor
    const inputTensor = tf.tensor2d([sensorData]);

    // Make prediction
    const prediction = model.predict(inputTensor) as tf.Tensor;
    const result = await prediction.data();

    // Store in database
    await db.query(
      'INSERT INTO predictions (field_id, sensor_data, yield_prediction, created_at) VALUES ($1, $2, $3, NOW())',
      [fieldId, sensorData, result[0]]
    );

    // Cache result
    const response = {
      fieldId,
      predictedYield: result[0],
      confidence: 0.92,
      timestamp: new Date().toISOString()
    };

    await redis.setEx(cacheKey, 3600, JSON.stringify(response));

    res.json(response);
  } catch (error) {
    logger.error('Prediction error:', error);
    res.status(500).json({ error: 'Prediction failed' });
  }
});

// Historical data endpoint
app.get('/history/:fieldId', async (req, res) => {
  try {
    const { fieldId } = req.params;
    const result = await db.query(
      'SELECT * FROM predictions WHERE field_id = $1 ORDER BY created_at DESC LIMIT 100',
      [fieldId]
    );
    res.json(result.rows);
  } catch (error) {
    logger.error('History query error:', error);
    res.status(500).json({ error: 'Query failed' });
  }
});

// Startup
async function start() {
  await loadModel();
  app.listen(port, () => {
    logger.info(`Crop yield predictor running on port ${port}`);
  });
}

start();