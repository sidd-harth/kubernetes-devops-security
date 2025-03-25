
Home
Explore
Help
Register
Sign In
bob
/
kubernetes-devops-security
Watch
1
Star
0
Fork
0
Code
Issues
Pull Requests
Projects
Releases
Wiki
Activity
devsecops app
3 Commits
1 Branch
0 Tags
329 KiB
kubernetes-devops-security/src/test/java/com/devsecops/NumericApplicationTests.java
61 lines
2.5 KiB
Raw
Permalink
Blame
History
package com.devsecops;


import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
//import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
//import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
public class NumericApplicationTests {

    @Autowired
    private MockMvc mockMvc;

    @Test
    public void smallerThanOrEqualToFiftyMessage() throws Exception {
        this.mockMvc.perform(get("/compare/50")).andDo(print()).andExpect(status().isOk())
          .andExpect(content().string("Smaller than or equal to 50"));
    }

    @Test
    public void greaterThanFiftyMessage() throws Exception {
        this.mockMvc.perform(get("/compare/51")).andDo(print()).andExpect(status().isOk())
                .andExpect(content().string("Greater than 50"));
    }

    @Test
    public void welcomeMessage() throws Exception {
         this.mockMvc.perform(get("/")).andDo(print()).andExpect(status().isOk())
           .andExpect(content().string("Kubernetes DevSecOps"));
    }
    
    @Test
    public void incrementByOneMessage() throws Exception {
         this.mockMvc.perform(get("/increment/50")).andDo(print()).andExpect(status().isOk())
           .andExpect(content().string("51"));
    }

}
Powered by Gitea Version: 1.14.1 Page: 286ms Template: 2ms
Licenses API Website Go1.16.3
