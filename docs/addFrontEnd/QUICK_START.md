# Quick Start Guide

## Running the Application

### Option 1: Run Both Services Manually

Open two terminal windows:

**Terminal 1 - Backend:**
```bash
npm run start:backend
# or
npx nx serve backend
```

**Terminal 2 - Frontend:**
```bash
npm run start:frontend
# or
npx nx serve frontend
```

### Option 2: Using package.json Scripts

```bash
# Start frontend (default)
npm start

# Start backend
npm run start:backend

# Build both
npm run build

# Build individually
npm run build:frontend
npm run build:backend

# Test
npm run test:frontend
npm run test:backend
```

## Accessing the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **Backend Health Check**: http://localhost:8080/barcodes/health

## Testing the API

```bash
# Health check
curl http://localhost:8080/barcodes/health

# Get all barcodes
curl http://localhost:8080/barcodes

# Add a barcode
curl -X POST http://localhost:8080/barcodes \
  -H "Content-Type: application/json" \
  -d '{"name":"My Card","data":"123456789"}'

# Delete a barcode
curl -X DELETE http://localhost:8080/barcodes/My%20Card
```

## Build Output

- Frontend: `dist/apps/frontend/`
- Backend: `apps/backend/target/backend-1.0-SNAPSHOT.jar`

## Troubleshooting

### Backend won't start
- Ensure Java 17 is installed: `java -version`
- Check if port 8080 is available: `lsof -i :8080`

### Frontend won't start
- Clear node_modules and reinstall: `rm -rf node_modules && npm install --legacy-peer-deps`
- Check if port 3000 is available: `lsof -i :3000`

### API calls fail
- Ensure both services are running
- Check CORS settings in BarcodeController.java
- Verify proxy settings in apps/frontend/vite.config.mjs
