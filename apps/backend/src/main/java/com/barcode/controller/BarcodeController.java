package com.barcode.controller;

import com.barcode.model.BarcodeItem;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/barcodes")
@CrossOrigin(origins = "http://localhost:3000")
public class BarcodeController {

    private List<BarcodeItem> barcodes = new ArrayList<>();

    @GetMapping
    public List<BarcodeItem> getAllBarcodes() {
        return barcodes;
    }

    @PostMapping
    public BarcodeItem addBarcode(@RequestBody BarcodeItem barcode) {
        barcodes.add(barcode);
        return barcode;
    }

    @DeleteMapping("/{name}")
    public void deleteBarcode(@PathVariable String name) {
        barcodes.removeIf(b -> b.getName().equals(name));
    }

    @GetMapping("/health")
    public String health() {
        return "Backend is running!";
    }
}
