# Barcode Wallet

A Progressive Web App (PWA) for managing and displaying barcodes on your phone. Built with React frontend and Java Spring Boot backend in an Nx monorepo.

## Features

- Add or delete barcodes to a list
- Display barcodes for scanning by barcode readers
- Offline support with PWA capabilities
- Local storage with IndexedDB
- Backend API for barcode management
- **PostgreSQL database for persistent storage**

## Project Structure

This is an Nx monorepo containing:
- **Frontend**: React + Vite PWA in `apps/frontend/`
- **Backend**: Java Spring Boot REST API in `apps/backend/`

## Getting Started

### Prerequisites

- Node.js 17+ and npm
- Java 17+
- Maven 3.9+
- PostgreSQL 12+ (for backend database)

### Installation

```bash
# Install dependencies
npm install --legacy-peer-deps
```

### Database Setup

The backend requires PostgreSQL for data persistence. See `docs/addPostgres/DATABASE_SETUP.md` for detailed setup instructions.

**Quick setup:**
```bash
# Create database and user
sudo -u postgres psql << EOF
CREATE DATABASE barcode;
CREATE USER barcode_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE barcode TO barcode_user;
\c barcode
GRANT ALL ON SCHEMA public TO barcode_user;
EOF

# Set environment variables
export DATABASE_URL=jdbc:postgresql://localhost:5432/barcode
export DATABASE_USERNAME=barcode_user
export DATABASE_PASSWORD=your_password
```

### Development

#### Start Backend
```bash
# With environment variables set
npx nx serve backend

# Or with inline environment variables
DATABASE_URL=jdbc:postgresql://localhost:5432/barcode \
DATABASE_USERNAME=barcode_user \
DATABASE_PASSWORD=your_password \
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

## Cloud Deployment

The application can be deployed to OVH Cloud using Terraform:

```bash
cd terraform
./deploy.sh
```

See the [Deployment Guide](docs/DEPLOYMENT_GUIDE.md) for complete instructions on deploying to OVH Cloud.

## Documentation

- `docs/DEPLOYMENT_GUIDE.md` - Complete OVH Cloud deployment guide
- `terraform/README.md` - Terraform infrastructure documentation
- `terraform/TERRAFORM_GUIDE.md` - Detailed Terraform module reference
- `docs/addFrontEnd/README.md` - Nx workspace setup and integration
- `docs/addPostgres/DATABASE_SETUP.md` - PostgreSQL database setup guide
- `docs/addPostgres/TEST_SUMMARY.md` - Database integration test results

## TODO

- desktop icon
- align barcode names to the left and delete buttons to the right
- print version to help debugging
- test brightness settings

## Credits

co-developed with ChatGPT and Claude
