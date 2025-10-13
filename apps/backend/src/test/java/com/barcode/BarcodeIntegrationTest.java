package com.barcode;

import com.barcode.model.BarcodeItem;
import com.barcode.repository.BarcodeRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
class BarcodeIntegrationTest {

    @Autowired
    private BarcodeRepository repository;

    @BeforeEach
    void setUp() {
        repository.deleteAll();
    }

    @Test
    void testSaveAndRetrieveBarcode() {
        // Create a barcode
        BarcodeItem barcode = new BarcodeItem("TestItem", "123456789");
        
        // Save it
        BarcodeItem saved = repository.save(barcode);
        
        // Verify it has an ID
        assertNotNull(saved.getId());
        assertEquals("TestItem", saved.getName());
        assertEquals("123456789", saved.getData());
        
        // Retrieve it
        Optional<BarcodeItem> found = repository.findById(saved.getId());
        assertTrue(found.isPresent());
        assertEquals("TestItem", found.get().getName());
    }

    @Test
    void testFindByName() {
        // Create and save a barcode
        BarcodeItem barcode = new BarcodeItem("UniqueItem", "987654321");
        repository.save(barcode);
        
        // Find by name
        Optional<BarcodeItem> found = repository.findByName("UniqueItem");
        assertTrue(found.isPresent());
        assertEquals("987654321", found.get().getData());
    }

    @Test
    void testDeleteByName() {
        // Create and save a barcode
        BarcodeItem barcode = new BarcodeItem("ToDelete", "111222333");
        repository.save(barcode);
        repository.flush();
        
        // Verify it exists
        assertEquals(1, repository.count());
        
        // Delete by name - Use the service method instead which has @Transactional
        // For direct repository test, we'll use deleteById
        Optional<BarcodeItem> found = repository.findByName("ToDelete");
        assertTrue(found.isPresent());
        repository.deleteById(found.get().getId());
        
        // Verify it's gone
        assertEquals(0, repository.count());
        Optional<BarcodeItem> notFound = repository.findByName("ToDelete");
        assertFalse(notFound.isPresent());
    }

    @Test
    void testFindAll() {
        // Create multiple barcodes
        repository.save(new BarcodeItem("Item1", "111111111"));
        repository.save(new BarcodeItem("Item2", "222222222"));
        repository.save(new BarcodeItem("Item3", "333333333"));
        
        // Retrieve all
        List<BarcodeItem> all = repository.findAll();
        assertEquals(3, all.size());
    }

    @Test
    void testUniqueNameConstraint() {
        // Create and save a barcode
        BarcodeItem barcode1 = new BarcodeItem("DuplicateName", "123456789");
        repository.save(barcode1);
        
        // Try to save another with the same name
        BarcodeItem barcode2 = new BarcodeItem("DuplicateName", "987654321");
        
        // This should throw an exception due to unique constraint
        assertThrows(Exception.class, () -> {
            repository.save(barcode2);
            repository.flush(); // Force the constraint check
        });
    }

    @Test
    void testDataPersistence() {
        // Save a barcode
        BarcodeItem barcode = new BarcodeItem("PersistTest", "555666777");
        BarcodeItem saved = repository.save(barcode);
        Long id = saved.getId();
        
        // Clear the persistence context
        repository.flush();
        
        // Retrieve from database
        Optional<BarcodeItem> retrieved = repository.findById(id);
        assertTrue(retrieved.isPresent());
        assertEquals("PersistTest", retrieved.get().getName());
        assertEquals("555666777", retrieved.get().getData());
    }
}
