package com.barcode;

import com.barcode.model.BarcodeItem;
import com.barcode.repository.BarcodeRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class BarcodeControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private BarcodeRepository repository;

    @Autowired
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        repository.deleteAll();
    }

    @Test
    void testHealthEndpoint() throws Exception {
        mockMvc.perform(get("/barcodes/health"))
                .andExpect(status().isOk())
                .andExpect(content().string("Backend is running!"));
    }

    @Test
    void testGetAllBarcodes_Empty() throws Exception {
        mockMvc.perform(get("/barcodes"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    @Test
    void testAddBarcode() throws Exception {
        BarcodeItem barcode = new BarcodeItem("TestItem", "123456789");
        
        mockMvc.perform(post("/barcodes")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(barcode)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("TestItem"))
                .andExpect(jsonPath("$.data").value("123456789"))
                .andExpect(jsonPath("$.id").exists());
    }

    @Test
    void testGetAllBarcodes_WithData() throws Exception {
        // Add some barcodes
        repository.save(new BarcodeItem("Item1", "111111111"));
        repository.save(new BarcodeItem("Item2", "222222222"));
        
        mockMvc.perform(get("/barcodes"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].name", is(oneOf("Item1", "Item2"))))
                .andExpect(jsonPath("$[1].name", is(oneOf("Item1", "Item2"))));
    }

    @Test
    void testDeleteBarcode() throws Exception {
        // Add a barcode
        BarcodeItem barcode = repository.save(new BarcodeItem("ToDelete", "999999999"));
        
        // Verify it exists
        mockMvc.perform(get("/barcodes"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)));
        
        // Delete it
        mockMvc.perform(delete("/barcodes/ToDelete"))
                .andExpect(status().isOk());
        
        // Verify it's gone
        mockMvc.perform(get("/barcodes"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    @Test
    void testEndToEndFlow() throws Exception {
        // Add multiple barcodes
        BarcodeItem barcode1 = new BarcodeItem("Card1", "111111111");
        BarcodeItem barcode2 = new BarcodeItem("Card2", "222222222");
        BarcodeItem barcode3 = new BarcodeItem("Card3", "333333333");
        
        mockMvc.perform(post("/barcodes")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(barcode1)))
                .andExpect(status().isOk());
        
        mockMvc.perform(post("/barcodes")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(barcode2)))
                .andExpect(status().isOk());
        
        mockMvc.perform(post("/barcodes")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(barcode3)))
                .andExpect(status().isOk());
        
        // Verify all exist
        mockMvc.perform(get("/barcodes"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(3)));
        
        // Delete one
        mockMvc.perform(delete("/barcodes/Card2"))
                .andExpect(status().isOk());
        
        // Verify only 2 remain
        mockMvc.perform(get("/barcodes"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)));
    }
}
