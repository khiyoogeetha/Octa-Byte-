const express = require('express');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

// PostgreSQL connection pool
// using env variables (PGHOST, PGUSER, PGDATABASE, PGPASSWORD, PGPORT)
const pool = new Pool();

app.use(express.json());

// Root route
app.get('/', (req, res) => {
  res.status(200).json({ 
    message: 'Welcome to the DevOps Assessment API!',
    available_endpoints: ['/health', '/db-health']
  });
});

// Basic health check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', message: 'API is running' });
});

// Database connection check
app.get('/db-health', async (req, res) => {
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT NOW() as currentTime');
    client.release();
    res.status(200).json({ 
      status: 'ok', 
      message: 'Connected to PostgreSQL successfully',
      time: result.rows[0].currenttime 
    });
  } catch (err) {
    console.error('Database connection error:', err);
    res.status(500).json({ 
      status: 'error', 
      message: 'Failed to connect to PostgreSQL',
      details: err.message
    });
  }
});

// Start server
const server = app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

// Graceful shutdown handling
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    pool.end(() => {
    	console.log('PostgreSQL pool has ended');
    });
  });
});
