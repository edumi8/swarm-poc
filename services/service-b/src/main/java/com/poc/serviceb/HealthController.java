package com.poc.serviceb;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;

@RestController
public class HealthController {
    
    // Cache static responses to avoid recreating HashMaps on every request
    private static final Map<String, String> HOME_RESPONSE = Map.of(
        "service", "service-b",
        "status", "running",
        "version", "1.0.0"
    );
    
    private static final Map<String, String> HEALTH_RESPONSE = Map.of(
        "status", "UP"
    );
    
    @GetMapping("/")
    public Map<String, String> home() {
        return HOME_RESPONSE;
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        return HEALTH_RESPONSE;
    }
}
