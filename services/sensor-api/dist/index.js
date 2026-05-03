"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3000;
app.use(express_1.default.json());
// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'healthy', service: 'sensor-api', timestamp: new Date().toISOString() });
});
// Get sensor data endpoint
app.get('/api/sensors', (req, res) => {
    res.json({
        sensors: [
            { id: 'sensor-001', type: 'soil-moisture', location: 'field-a', value: 42.5 },
            { id: 'sensor-002', type: 'temperature', location: 'field-a', value: 22.3 },
            { id: 'sensor-003', type: 'soil-moisture', location: 'field-b', value: 38.1 }
        ]
    });
});
// Submit sensor reading endpoint
app.post('/api/sensors/:id/readings', (req, res) => {
    const { id } = req.params;
    const { value } = req.body;
    if (value === undefined) {
        res.status(400).json({ error: 'Reading value is required' });
        return;
    }
    res.status(201).json({
        message: 'Reading recorded',
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
exports.default = app;
