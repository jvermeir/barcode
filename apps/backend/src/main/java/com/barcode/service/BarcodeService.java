package com.barcode.service;

import com.barcode.model.BarcodeItem;
import com.barcode.repository.BarcodeRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class BarcodeService {
    
    private final BarcodeRepository repository;
    
    public BarcodeService(BarcodeRepository repository) {
        this.repository = repository;
    }
    
    public List<BarcodeItem> getAllBarcodes() {
        return repository.findAll();
    }
    
    public BarcodeItem addBarcode(BarcodeItem barcode) {
        return repository.save(barcode);
    }
    
    @Transactional
    public void deleteBarcode(String name) {
        repository.deleteByName(name);
    }
}
