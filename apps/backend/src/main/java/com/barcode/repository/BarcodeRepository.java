package com.barcode.repository;

import com.barcode.model.BarcodeItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface BarcodeRepository extends JpaRepository<BarcodeItem, Long> {
    Optional<BarcodeItem> findByName(String name);
    void deleteByName(String name);
}
