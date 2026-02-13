require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

// Import routes
const authRoutes = require('./routes/auth.routes');
const courseRoutes = require('./routes/course.routes');
const studentRoutes = require('./routes/student.routes');
const noticeRoutes = require('./routes/notice.routes');
const downloadRoutes = require('./routes/download.routes');
const syncRoutes = require('./routes/sync.routes');
const documentRoutes = require('./routes/documents.routes');

const app = express();

// Security Middleware
app.use(helmet());
app.use(cors({
    origin: '*', // In production, specify your app's domain
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Logging
app.use(morgan('dev'));

// Body Parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Health Check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API Routes
const API_VERSION = process.env.API_VERSION || 'v1';
app.use(`/api/${API_VERSION}/auth`, authRoutes);
app.use(`/api/${API_VERSION}/courses`, courseRoutes);
app.use(`/api/${API_VERSION}/students`, studentRoutes);
app.use(`/api/${API_VERSION}/notices`, noticeRoutes);
app.use(`/api/${API_VERSION}/downloads`, downloadRoutes);
app.use(`/api/${API_VERSION}/sync`, syncRoutes);
app.use(`/api/${API_VERSION}/documents`, documentRoutes);

// 404 Handler
app.use((req, res) => {
    res.status(404).json({ error: 'Route not found' });
});

// Global Error Handler
app.use((err, req, res, next) => {
    console.error('🔥 Error:', err.stack);
    res.status(err.status || 500).json({
        error: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error',
    });
});

// Start Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
    console.log(`📚 API Docs: http://localhost:${PORT}/api/${API_VERSION}`);
});

module.exports = app;
