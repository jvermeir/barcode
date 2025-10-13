package com.barcode.controller;

import com.barcode.model.BarcodeItem;
import com.barcode.service.BarcodeService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/barcodes")
@CrossOrigin(origins = "http://localhost:3000")
public class BarcodeController {

    private final BarcodeService barcodeService;

    public BarcodeController(BarcodeService barcodeService) {
        this.barcodeService = barcodeService;
    }

    @GetMapping
    public List<BarcodeItem> getAllBarcodes() {
        return barcodeService.getAllBarcodes();
    }

    @PostMapping
    public BarcodeItem addBarcode(@RequestBody BarcodeItem barcode) {
        return barcodeService.addBarcode(barcode);
    }

    @DeleteMapping("/{name}")
    public void deleteBarcode(@PathVariable String name) {
        barcodeService.deleteBarcode(name);
    }

    @GetMapping("/health")
    public String health() {
        return "Backend is running!";
    }
}
