# Barcode Wallet

A Progressive Web App (PWA) for managing and displaying barcodes on your phone. Built with React frontend and Java Spring Boot backend in an Nx monorepo.

## Features

- Add or delete barcodes to a list
- Display barcodes for scanning by barcode readers
- Offline support with PWA capabilities
- Local storage with IndexedDB
- Backend API for barcode management

## Project Structure

This is an Nx monorepo containing:
- **Frontend**: React + Vite PWA in `apps/frontend/`
- **Backend**: Java Spring Boot REST API in `apps/backend/`

## Getting Started

### Prerequisites

- Node.js 17+ and npm
- Java 17+
- Maven 3.9+

### Installation

```bash
# Install dependencies
npm install --legacy-peer-deps
```

### Development

#### Start Backend
```bash
npx nx serve backend
```
Backend will start on http://localhost:8080

#### Start Frontend
```bash
npx nx serve frontend
```
Frontend will start on http://localhost:3000

### Building for Production

```bash
# Build backend
npx nx build backend

# Build frontend
npx nx build frontend
```

### Testing

```bash
# Test backend
npx nx test backend

# Test frontend
npx nx test frontend
```

## API Endpoints

- `GET /barcodes/health` - Health check
- `GET /barcodes` - Get all barcodes
- `POST /barcodes` - Add a barcode
- `DELETE /barcodes/{name}` - Delete a barcode

## Documentation

See `docs/addFrontEnd/README.md` for detailed documentation on the Nx workspace setup and integration.

## TODO

- desktop icon
- align barcode names to the left and delete buttons to the right
- print version to help debugging
- test brightness settings
- integrate frontend with backend API

## Credits

co-developed with ChatGPT and Claude
