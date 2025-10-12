import React, {useState, useEffect} from "react";
import {Input} from "./components/ui/input";
import {Button} from "./components/ui/button";
import {Card, CardContent} from "./components/ui/card";
import {Barcode, Trash2} from "lucide-react";
import JsBarcode from "jsbarcode";
import {openDB} from 'idb';


// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
const firebaseConfig = {
    apiKey: "AIzaSyB8AkBV9gMZuhfs0DgJ-3MtT5xvrbT-oME",
    authDomain: "barcode-6dac3.firebaseapp.com",
    projectId: "barcode-6dac3",
    storageBucket: "barcode-6dac3.firebasestorage.app",
    messagingSenderId: "957376186823",
    appId: "1:957376186823:web:363f93b4a56e39c21af1e2"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

interface BarCodeItem {
    name: string;
    data: string;
}

const APP_VERSION = process.env.REACT_APP_VERSION || "unknown";

export default function BarCodeApp() {
    const [barcodeData, setBarcodeData] = useState("");
    const [barcodeName, setBarcodeName] = useState("");
    const [barcodes, setBarcodes] = useState<BarCodeItem[]>([]);
    const DB_NAME = 'barcode-wallet';
    const STORE_NAME = 'barcodes';

    useEffect(() => {
        loadBarcodes().then(setBarcodes);
    }, []);

    useEffect(() => {
        saveBarcodes(barcodes);
    }, [barcodes]);

    async function saveBarcodes(barcodes: BarCodeItem[]) {
        const db = await openDB(DB_NAME, 1, {
            upgrade(db) {
                if (!db.objectStoreNames.contains(STORE_NAME)) {
                    db.createObjectStore(STORE_NAME, {keyPath: 'name'});
                }
            },
        });
        const tx = db.transaction(STORE_NAME, 'readwrite');
        const store = tx.objectStore(STORE_NAME);
        for (const barcode of barcodes) {
            await store.put(barcode);
        }
        await tx.done;
    }

    async function loadBarcodes(): Promise<BarCodeItem[]> {
        const db = await openDB(DB_NAME, 1, {
            upgrade(db) {
                if (!db.objectStoreNames.contains(STORE_NAME)) {
                    db.createObjectStore(STORE_NAME, {keyPath: 'name'});
                }
            },
        });
        const tx = db.transaction(STORE_NAME, 'readonly');
        const store = tx.objectStore(STORE_NAME);
        return (await store.getAll()) || [];
    }

    const [selectedBarcode, setSelectedBarcode] = useState<BarCodeItem | null>(null);

    useEffect(() => {
        localStorage.setItem("barcodes", JSON.stringify(barcodes));
    }, [barcodes]);

    useEffect(() => {
        let wakeLock: any = null;

        const requestWakeLock = async () => {
            try {
                // The Wake Lock API is experimental and may not be available in all browsers
                if ('wakeLock' in navigator) {
                    wakeLock = await (navigator as any).wakeLock.request('screen');
                }
            } catch (err) {
                console.error('Wake Lock error:', err);
            }
        };

        if (selectedBarcode) {
            // Render barcode
            const canvas = document.getElementById("barcode-canvas");
            JsBarcode(canvas, selectedBarcode.data, {
                displayValue: true,
                width: 2,          // Width of each bar
                height: 100,       // Height of the barcode
                margin: 10,        // Margin around the barcode
                format: "CODE128", // Format type
                background: "#ffffff",
                lineColor: "#000000"
            });

            // Maximize brightness
            document.documentElement.style.backgroundColor = "#FFFFFF";
            document.body.style.backgroundColor = "#FFFFFF";
            const originalBrightness = document.body.style.filter;
            document.body.style.filter = "brightness(120%)";

            // Prevent screen from dimming
            requestWakeLock();

            return () => {
                // Release wake lock when component unmounts or barcode closes
                if (wakeLock) {
                    wakeLock.release().catch((err: Error) => {
                        console.error('Wake Lock release error:', err);
                    });
                }

                // Reset brightness
                document.body.style.filter = originalBrightness;
                document.documentElement.style.backgroundColor = "";
                document.body.style.backgroundColor = "";
            };
        }
    }, [selectedBarcode]);

    const addBarcode = () => {
        if (!barcodeName || !barcodeData) return;
        const newBarcode = {name: barcodeName, data: barcodeData};
        setBarcodes([...barcodes, newBarcode]);
        setBarcodeName("");
        setBarcodeData("");
    };

    const deleteBarcode = (index: number, e: React.MouseEvent) => {
        e.stopPropagation(); // Prevent triggering the barcode selection
        const newBarcodes = [...barcodes];
        newBarcodes.splice(index, 1);
        setBarcodes(newBarcodes);
    };

    return (
        <div className="p-4 max-w-md mx-auto">
            <div className="absolute top-0 left-0 p-2 text-xxs text-gray-500">
                version: {APP_VERSION}
            </div>
            <h1 className="text-xl font-bold mb-4">Barcode Wallet</h1>

            {!selectedBarcode && (
                <>
                    <Card className="mb-4">
                        <CardContent className="p-4 space-y-2">
                            <Input
                                placeholder="Name (e.g., Loyalty Card)"
                                value={barcodeName}
                                onChange={(e) => setBarcodeName(e.target.value)}
                            />
                            <Input
                                placeholder="Barcode Number"
                                value={barcodeData}
                                onChange={(e) => setBarcodeData(e.target.value)}
                            />
                            <Button onClick={addBarcode}>Add Barcode</Button>
                        </CardContent>
                    </Card>

                    <h2 className="text-lg font-semibold mb-2 mt-6">Your Barcodes</h2>

                    {barcodes.map((b, index) => (
                        <div
                            key={index}
                            className="grid grid-cols-2 gap-4 text-left"
                            style={{ gridTemplateColumns: "1fr 1fr" }}
                        >
                            <Button
                                className="w-64 h-14 justify-start text-left overflow-hidden border border-gray-200 bg-white text-black hover:bg-gray-100"
                                onClick={() => setSelectedBarcode(b)}
                                style={{  width: "200px", textAlign: "left" }} // Ensures text alignment to the left
                            >
                                <Barcode className="mr-2 h-6 w-6 flex-shrink-0" />
                                <span className="truncate">{b.name}</span>
                            </Button>
                            <Button
                                onClick={(e) => deleteBarcode(index, e)}
                                className="h-14 w-14 flex-shrink-0 bg-red-600 hover:bg-red-700 p-0"
                            >
                                <Trash2 className="h-6 w-6" />
                            </Button>
                        </div>
                    ))}
                </>
            )}

            {selectedBarcode && (
                <div
                    className="fixed top-0 left-0 w-screen h-screen bg-white flex flex-col items-center justify-center z-50"
                    onClick={() => setSelectedBarcode(null)}
                >
                    <canvas
                        id="barcode-canvas"
                        className="w-full max-w-xs"
                        style={{width: "300px"}} // Fixed width for consistency
                    />
                    <p className="mt-2 text-lg">{selectedBarcode.name}</p>
                    <p className="text-sm text-gray-500">Tap to go back</p>
                </div>
            )}
        </div>
    );
}