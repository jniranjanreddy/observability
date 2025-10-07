// Node.js application with OpenTelemetry
// package.json dependencies
/*
{
  "dependencies": {
    "@opentelemetry/api": "^1.7.0",
    "@opentelemetry/sdk-node": "^0.45.0",
    "@opentelemetry/exporter-jaeger": "^1.18.0",
    "@opentelemetry/instrumentation-http": "^0.45.0",
    "@opentelemetry/instrumentation-express": "^0.34.0"
  }
}
*/

// tracing.js - Initialize tracing before importing other modules
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { JaegerExporter } = require('@opentelemetry/exporter-jaeger');
const { HttpInstrumentation } = require('@opentelemetry/instrumentation-http');
const { ExpressInstrumentation } = require('@opentelemetry/instrumentation-express');

const jaegerExporter = new JaegerExporter({
  endpoint: 'http://localhost:14268/api/traces',
});

const sdk = new NodeSDK({
  traceExporter: jaegerExporter,
  instrumentations: [
    new HttpInstrumentation(),
    new ExpressInstrumentation(),
  ],
  serviceName: 'user-api',
  serviceVersion: '1.0.0',
});

sdk.start();

// app.js - Main application
require('./tracing'); // Import tracing first

const express = require('express');
const { trace, context, SpanStatusCode } = require('@opentelemetry/api');

const app = express();
const tracer = trace.getTracer('user-api');

app.use(express.json());

// Middleware to add trace context to logs
app.use((req, res, next) => {
  const span = trace.getActiveSpan();
  if (span) {
    req.traceId = span.spanContext().traceId;
    req.spanId = span.spanContext().spanId;
  }
  next();
});

app.get('/users/:id', async (req, res) => {
  const span = tracer.startSpan('get-user', {
    attributes: {
      'user.id': req.params.id,
      'http.method': req.method,
      'http.url': req.url
    }
  });

  try {
    console.log(`Fetching user ${req.params.id} trace_id=${req.traceId} span_id=${req.spanId}`);
    
    // Simulate database call
    const user = await getUserFromDatabase(req.params.id);
    
    span.setStatus({ code: SpanStatusCode.OK });
    res.json(user);
    
  } catch (error) {
    span.setStatus({ 
      code: SpanStatusCode.ERROR, 
      message: error.message 
    });
    console.error(`Error fetching user trace_id=${req.traceId} span_id=${req.spanId}: ${error.message}`);
    res.status(500).json({ error: error.message });
  } finally {
    span.end();
  }
});

async function getUserFromDatabase(userId) {
  const span = tracer.startSpan('database-query', {
    attributes: {
      'db.operation': 'SELECT',
      'db.table': 'users',
      'user.id': userId
    }
  });

  try {
    // Simulate async database operation
    await new Promise(resolve => setTimeout(resolve, 100));
    return { id: userId, name: `User ${userId}`, email: `user${userId}@example.com` };
  } finally {
    span.end();
  }
}

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
