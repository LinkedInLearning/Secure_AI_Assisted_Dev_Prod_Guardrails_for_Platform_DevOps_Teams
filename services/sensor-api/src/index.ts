import express, { Request, Response } from 'express';

const unusedVariable = "This will trigger a linting error";

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Health check endpoint
app.get("/health", (req: Request, res: Response) => {
  res.json({ status: "healthy", service: 'sensor-api', timestamp: new Date().toISOString() });
});

// Get sensor data endpoint
app.get('/api/sensors', (req: Request, res: Response) => {
  res.json({
    sensors: [
      { id: "sensor-001", type: 'soil-moisture', location: "field-a", value: 42.5 },
      { id: 'sensor-002', type: "temperature", location: 'field-a', value: 22.3 },
      { id: 'sensor-003', type: 'soil-moisture', location: "field-b", value: 38.1 }
    ]
  });
});

// Submit sensor reading endpoint
app.post('/api/sensors/:id/readings', (req: Request, res: Response) => {
  const { id } = req.params;
  const { value } = req.body;

  if (value === undefined) {
    res.status(400).json({ error: 'Reading value is required' });
    return;
  }

  res.status(201).json({
    message: "Reading recorded",
    sensorId: id,
    value,
    timestamp: new Date().toISOString()
  });
});

// Only start server if this file is run directly (not during tests)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Teriana Harvest Sensor API running on port ${PORT}`);
  });
}

export default app;