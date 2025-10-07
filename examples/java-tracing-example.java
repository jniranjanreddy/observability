// Java Spring Boot application with OpenTelemetry
// pom.xml dependencies
/*
<dependency>
    <groupId>io.opentelemetry</groupId>
    <artifactId>opentelemetry-api</artifactId>
    <version>1.32.0</version>
</dependency>
<dependency>
    <groupId>io.opentelemetry</groupId>
    <artifactId>opentelemetry-exporter-jaeger</artifactId>
    <version>1.32.0</version>
</dependency>
*/

@RestController
public class UserController {
    
    private static final Tracer tracer = GlobalOpenTelemetry.getTracer("user-service");
    private static final Logger logger = LoggerFactory.getLogger(UserController.class);
    
    @GetMapping("/users/{id}")
    public ResponseEntity<User> getUser(@PathVariable String id) {
        Span span = tracer.spanBuilder("get-user")
            .setAttribute("user.id", id)
            .startSpan();
            
        try (Scope scope = span.makeCurrent()) {
            logger.info("Fetching user with ID: {} trace_id={} span_id={}", 
                id, span.getSpanContext().getTraceId(), span.getSpanContext().getSpanId());
            
            User user = userService.findById(id);
            span.setStatus(StatusCode.OK);
            return ResponseEntity.ok(user);
            
        } catch (Exception e) {
            span.setStatus(StatusCode.ERROR, e.getMessage());
            logger.error("Error fetching user trace_id={} span_id={}: {}", 
                span.getSpanContext().getTraceId(), span.getSpanContext().getSpanId(), e.getMessage());
            throw e;
        } finally {
            span.end();
        }
    }
}

// Application configuration
@Configuration
public class TracingConfiguration {
    
    @Bean
    public OpenTelemetry openTelemetry() {
        return OpenTelemetrySdk.builder()
            .setTracerProvider(
                SdkTracerProvider.builder()
                    .addSpanProcessor(BatchSpanProcessor.builder(
                        JaegerGrpcSpanExporter.builder()
                            .setEndpoint("http://localhost:14250")
                            .build())
                        .build())
                    .setResource(Resource.getDefault()
                        .merge(Resource.builder()
                            .put(ResourceAttributes.SERVICE_NAME, "user-service")
                            .put(ResourceAttributes.SERVICE_VERSION, "1.0.0")
                            .build()))
                    .build())
            .build();
    }
}
