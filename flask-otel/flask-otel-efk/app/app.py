import logging
import os
import sys
from flask import Flask
from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.flask import FlaskInstrumentor

# ----------------------------------------------------------------
# Logging setup
# ----------------------------------------------------------------
logging.basicConfig(
    level=logging.DEBUG,  # DEBUG gives detailed startup info
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger("flask-debug")

logger.info("🚀 Starting Flask application with OpenTelemetry...")

# ----------------------------------------------------------------
# OpenTelemetry setup with extra debugging
# ----------------------------------------------------------------
try:
    resource = Resource(attributes={"service.name": "flask-demo"})
    provider = TracerProvider(resource=resource)
    exporter_endpoint = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://jaeger:4318/v1/traces")
    logger.info(f"Configuring OTLP exporter at {exporter_endpoint}")
    processor = BatchSpanProcessor(OTLPSpanExporter(endpoint=exporter_endpoint))
    provider.add_span_processor(processor)
    trace.set_tracer_provider(provider)
    tracer = trace.get_tracer(__name__)
    logger.info("✅ OpenTelemetry tracer initialized successfully")
except Exception as e:
    logger.exception("❌ Failed to initialize OpenTelemetry:")
    sys.exit(1)

# ----------------------------------------------------------------
# Flask setup
# ----------------------------------------------------------------
try:
    app = Flask(__name__)
    FlaskInstrumentor().instrument_app(app)
    logger.info("✅ Flask instrumented successfully for OpenTelemetry")
except Exception as e:
    logger.exception("❌ Failed to instrument Flask:")
    sys.exit(1)

# ----------------------------------------------------------------
# Routes
# ----------------------------------------------------------------
@app.route('/')
def hello():
    logger.info("Root endpoint hit")
    return "Hello from Flask with OpenTelemetry!"

@app.route('/work')
def work():
    logger.info("Work endpoint hit")
    return "Doing some work..."

# ----------------------------------------------------------------
# Entry point
# ----------------------------------------------------------------
if __name__ == "__main__":
    try:
        host = "0.0.0.0"
        port = int(os.getenv("PORT", 5000))
        logger.info(f"🌐 Starting Flask server on {host}:{port}")
        app.run(host=host, port=port)
    except Exception as e:
        logger.exception("❌ Flask app failed to start:")
        sys.exit(1)

