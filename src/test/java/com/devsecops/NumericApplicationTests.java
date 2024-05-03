package com.devsecops;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class NumericApplicationTests {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void smallerThanOrEqualToFiftyMessage() throws Exception {
        mockMvc.perform(MockMvcRequestBuilders.get("/compare/50"))
               .andDo(print())
               .andExpect(status().isOk())
               .andExpect(content().string("Smaller than or equal to 50"));
    }

    @Test
    void greaterThanFiftyMessage() throws Exception {
        mockMvc.perform(MockMvcRequestBuilders.get("/compare/51"))
               .andDo(print())
               .andExpect(status().isOk())
               .andExpect(content().string("Greater than 50"));
    }

    @Test
    void welcomeMessage() throws Exception {
        mockMvc.perform(MockMvcRequestBuilders.get("/"))
               .andDo(print())
               .andExpect(status().isOk())
               .andExpect(content().string("Kubernetes DevSecOps"));
    }

    // Consider adding more tests for error handling cases and other HTTP methods
}
