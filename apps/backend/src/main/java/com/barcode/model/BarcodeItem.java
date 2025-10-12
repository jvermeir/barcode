package com.barcode.model;

public class BarcodeItem {
    private String name;
    private String data;

    public BarcodeItem() {
    }

    public BarcodeItem(String name, String data) {
        this.name = name;
        this.data = data;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }
}
