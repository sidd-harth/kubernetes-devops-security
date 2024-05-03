package com.devsecops;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
public class NumericController {

    private final Logger logger = LoggerFactory.getLogger(getClass());
    private static final String BASE_URL = "http://node-service:5000/plusone";
    private final RestTemplate restTemplate = new RestTemplate();

    @RestController
    public class Compare {

        @GetMapping("/")
        String welcome() {
            return "Kubernetes DevSecOps";
        }

        @GetMapping("/compare/{value}")
        String compareToFifty(@PathVariable int value) {
            return value > 50 ? "Greater than 50" : "Smaller than or equal to 50";
        }

        @GetMapping("/increment/{value}")
        int increment(@PathVariable int value) {
            try {
                ResponseEntity<String> responseEntity = restTemplate.getForEntity(BASE_URL + '/' + value, String.class);
                String response = responseEntity.getBody();
                logger.info("Value Received in Request - {}", value);
                logger.info("Node Service Response - {}", response);
                return Integer.parseInt(response);
            } catch (NumberFormatException e) {
                logger.error("Error parsing response to integer", e);
                throw new RuntimeException("Failed to parse the response from Node Service");
            }
        }
    }
}
