# Quick Start Guide - PostgreSQL Integration

This guide will get you up and running with the PostgreSQL-backed Barcode Wallet in under 5 minutes.

## Prerequisites Check

Make sure you have:
```bash
node --version   # Should be 17+
java --version   # Should be 17+
mvn --version    # Should be 3.9+
psql --version   # Should be 12+
```

## Step 1: Install PostgreSQL (if not installed)

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

### macOS
```bash
brew install postgresql@14
brew services start postgresql@14
```

### Windows
Download and install from [postgresql.org](https://www.postgresql.org/download/windows/)

## Step 2: Create Database

```bash
sudo -u postgres psql << 'EOF'
CREATE DATABASE barcode;
CREATE USER barcode_user WITH PASSWORD 'dev_password_123';
GRANT ALL PRIVILEGES ON DATABASE barcode TO barcode_user;
\c barcode
GRANT ALL ON SCHEMA public TO barcode_user;
\q
EOF
```

## Step 3: Configure Environment

Create a `.env` file in the project root:
```bash
cat > .env << 'EOF'
DATABASE_URL=jdbc:postgresql://localhost:5432/barcode
DATABASE_USERNAME=barcode_user
DATABASE_PASSWORD=dev_password_123
EOF
```

> **Note**: The `.env` file is ignored by git and won't be committed.

## Step 4: Install Dependencies

```bash
npm install --legacy-peer-deps
```

## Step 5: Start the Backend

```bash
# Load environment variables and start backend
source .env
npx nx serve backend
```

Wait for the message:
```
Started Application in X.XXX seconds
```

## Step 6: Test the API

In another terminal:
```bash
# Health check
curl http://localhost:8080/barcodes/health

# Get all barcodes (should be empty)
curl http://localhost:8080/barcodes

# Add a barcode
curl -X POST http://localhost:8080/barcodes \
  -H "Content-Type: application/json" \
  -d '{"name":"TestCard","data":"1234567890"}'

# Get all barcodes (should have 1 item)
curl http://localhost:8080/barcodes
```

## Step 7: Start the Frontend (Optional)

```bash
npx nx serve frontend
```

Visit http://localhost:3000 in your browser.

## Verify Database

Check that data is in PostgreSQL:
```bash
sudo -u postgres psql -d barcode -c "SELECT * FROM barcode_items;"
```

## What's Next?

- Read `DATABASE_SETUP.md` for detailed configuration options
- Check `TEST_SUMMARY.md` for test results
- Deploy to production (see production setup in `DATABASE_SETUP.md`)

## Troubleshooting

### Connection Refused
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Or on macOS
brew services list
```

### Authentication Failed
```bash
# Reset password
sudo -u postgres psql -c "ALTER USER barcode_user PASSWORD 'dev_password_123';"
```

### Permission Denied
```bash
# Grant schema permissions
sudo -u postgres psql -d barcode -c "GRANT ALL ON SCHEMA public TO barcode_user;"
```

## Environment Variables

The application uses these environment variables:
- `DATABASE_URL` - JDBC connection string
- `DATABASE_USERNAME` - Database username
- `DATABASE_PASSWORD` - Database password

Default values (if not set):
- URL: `jdbc:postgresql://localhost:5432/barcode`
- Username: `postgres`
- Password: `postgres`

## Success Criteria

You know everything is working when:
1. ✅ Backend starts without errors
2. ✅ `/barcodes/health` returns "Backend is running!"
3. ✅ You can add/get/delete barcodes via API
4. ✅ Data appears in PostgreSQL database
5. ✅ Data persists after backend restart
