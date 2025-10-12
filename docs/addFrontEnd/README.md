# Frontend and Backend Integration with Nx

This document describes the integration of a React frontend and Java Spring Boot backend into an Nx workspace.

## Project Structure

```
barcode/
├── apps/
│   ├── backend/          # Java Spring Boot backend
│   │   ├── src/
│   │   │   ├── main/
│   │   │   │   ├── java/com/barcode/
│   │   │   │   │   ├── Application.java
│   │   │   │   │   ├── controller/
│   │   │   │   │   │   └── BarcodeController.java
│   │   │   │   │   └── model/
│   │   │   │   │       └── BarcodeItem.java
│   │   │   │   └── resources/
│   │   │   │       └── application.properties
│   │   │   └── test/
│   │   ├── pom.xml
│   │   └── project.json
│   │
│   └── frontend/         # React frontend
│       ├── src/
│       ├── public/
│       ├── vite.config.mjs
│       └── project.json
├── docs/
│   └── addFrontEnd/      # Documentation and logs
├── nx.json
└── package.json
```

## Technologies Used

### Frontend
- **React 19.1.0** - UI framework
- **Vite 7.1.9** - Build tool and dev server
- **TypeScript 5.3.3** - Type-safe JavaScript
- **Lucide React** - Icon library
- **JsBarcode** - Barcode generation
- **IndexedDB (idb)** - Local storage

### Backend
- **Java 17** - Programming language
- **Spring Boot 3.2.0** - Backend framework
- **Maven** - Build tool and dependency management

### Build System
- **Nx 21.6.4** - Monorepo build system

## Nx Workspace Configuration

The workspace is configured with the following targets:

### Backend (apps/backend)
- `nx build backend` - Builds the Java application using Maven
- `nx serve backend` - Starts the Spring Boot application
- `nx test backend` - Runs backend tests

### Frontend (apps/frontend)
- `nx build frontend` - Builds the React application for production
- `nx serve frontend` - Starts the development server
- `nx test frontend` - Runs frontend tests

## Backend REST API

The backend provides a REST API for managing barcodes:

### Endpoints

1. **Health Check**
   - `GET /barcodes/health`
   - Returns: "Backend is running!"

2. **Get All Barcodes**
   - `GET /barcodes`
   - Returns: Array of barcode items

3. **Add Barcode**
   - `POST /barcodes`
   - Body: `{"name": "string", "data": "string"}`
   - Returns: Created barcode item

4. **Delete Barcode**
   - `DELETE /barcodes/{name}`
   - Returns: void

### CORS Configuration

The backend is configured with CORS to allow requests from `http://localhost:3000` (frontend dev server).

## Frontend-Backend Integration

### Proxy Configuration

The frontend is configured with a proxy in `vite.config.mjs` to forward API requests to the backend:

```javascript
server: {
  port: 3000,
  open: true,
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true,
      rewrite: (path) => path.replace(/^\/api/, '')
    }
  }
}
```

This allows the frontend to make requests to `/api/barcodes` which will be proxied to `http://localhost:8080/barcodes`.

## Running the Application

### Start Both Services

1. **Start Backend**:
   ```bash
   npx nx serve backend
   ```
   Backend will start on port 8080.

2. **Start Frontend** (in a new terminal):
   ```bash
   npx nx serve frontend
   ```
   Frontend will start on port 3000 and open in your browser.

### Build for Production

```bash
# Build backend
npx nx build backend

# Build frontend
npx nx build frontend
```

## Testing the API

Example API calls:

```bash
# Health check
curl http://localhost:8080/barcodes/health

# Get all barcodes
curl http://localhost:8080/barcodes

# Add a barcode
curl -X POST http://localhost:8080/barcodes \
  -H "Content-Type: application/json" \
  -d '{"name":"test","data":"123456789"}'

# Delete a barcode
curl -X DELETE http://localhost:8080/barcodes/test
```

## Logs

Service logs are captured in:
- `backend-startup.log` - Backend service startup logs
- `frontend-startup.log` - Frontend service startup logs

## Next Steps

1. Connect the React frontend to use the backend API
2. Replace local IndexedDB storage with backend API calls
3. Implement error handling for API failures
4. Add authentication if needed
5. Deploy both services to production
