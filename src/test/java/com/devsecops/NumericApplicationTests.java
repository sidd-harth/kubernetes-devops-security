package com.devsecops;

import org.junit.jupiter.api.Test; // JUnit 5 import
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders; // Import
import org.springframework.test.web.servlet.result.MockMvcResultHandlers; // Import
import org.springframework.test.web.servlet.result.MockMvcResultMatchers; // Import

import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;

@SpringBootTest 
@AutoConfigureMockMvc
public class NumericApplicationTests {

    @Autowired
    private MockMvc mockMvc;

    @Test
    public void smallerThanOrEqualToFiftyMessage() throws Exception {
        this.mockMvc.perform(MockMvcRequestBuilders.get("/compare/50")) 
                .andDo(MockMvcResultHandlers.print())
                .andExpect(status().isOk())
                .andExpect(content().string("Smaller than or equal to 50"));
    }

    @Test
    public void greaterThanFiftyMessage() throws Exception {
        this.mockMvc.perform(MockMvcRequestBuilders.get("/compare/51")) 
                .andDo(MockMvcResultHandlers.print())
                .andExpect(status().isOk())
                .andExpect(content().string("Greater than 50"));
    }

    @Test
    public void welcomeMessage() throws Exception {
        this.mockMvc.perform(MockMvcRequestBuilders.get("/")) 
                .andDo(MockMvcResultHandlers.print())
                .andExpect(status().isOk())
                .andExpect(content().string("Kubernetes DevSecOps"));
    }
}
