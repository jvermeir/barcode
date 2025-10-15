# PostgreSQL Database Setup Guide

## Overview

The Barcode Wallet backend now uses PostgreSQL for persistent data storage. This ensures that barcode data is not lost when the backend restarts.

## Local Development Setup

### Prerequisites

- PostgreSQL 12 or higher
- Java 17+
- Maven 3.9+

### 1. Install PostgreSQL

#### On Ubuntu/Debian:
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

#### On macOS:
```bash
brew install postgresql@14
brew services start postgresql@14
```

#### On Windows:
Download and install from [postgresql.org](https://www.postgresql.org/download/windows/)

### 2. Create Database and User

```bash
# Connect to PostgreSQL as postgres user
sudo -u postgres psql

# Create database
CREATE DATABASE barcode;

# Create user with password
CREATE USER barcode_user WITH PASSWORD 'your_secure_password';

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE barcode TO barcode_user;

# Exit
\q
```

### 3. Configure Environment Variables

Set the following environment variables before starting the backend:

```bash
export DATABASE_URL=jdbc:postgresql://localhost:5432/barcode
export DATABASE_USERNAME=barcode_user
export DATABASE_PASSWORD=your_secure_password
```

Or create a `.env` file in the project root (this file should NOT be committed to git):

```
DATABASE_URL=jdbc:postgresql://localhost:5432/barcode
DATABASE_USERNAME=barcode_user
DATABASE_PASSWORD=your_secure_password
```

### 4. Start the Backend

```bash
# With environment variables set
npx nx serve backend

# Or with inline environment variables
DATABASE_URL=jdbc:postgresql://localhost:5432/barcode \
DATABASE_USERNAME=barcode_user \
DATABASE_PASSWORD=your_secure_password \
npx nx serve backend
```

## Production Setup

### Using Docker

```bash
# Run PostgreSQL in Docker
docker run --name barcode-postgres \
  -e POSTGRES_DB=barcode \
  -e POSTGRES_USER=barcode_user \
  -e POSTGRES_PASSWORD=secure_password \
  -p 5432:5432 \
  -d postgres:14
```

### Using Cloud Services

For cloud deployments (AWS RDS, Google Cloud SQL, Azure Database, etc.):

1. Create a PostgreSQL instance in your cloud provider
2. Note the connection details (host, port, database name)
3. Create a database user with appropriate permissions
4. Set environment variables in your deployment configuration:
   - `DATABASE_URL`: Full JDBC URL (e.g., `jdbc:postgresql://your-instance.region.rds.amazonaws.com:5432/barcode`)
   - `DATABASE_USERNAME`: Database username
   - `DATABASE_PASSWORD`: Database password (use secrets manager!)

### Security Best Practices

1. **Never commit credentials to git**
   - Use environment variables
   - Use secrets management services (AWS Secrets Manager, Azure Key Vault, etc.)
   - Add `.env` files to `.gitignore`

2. **Use strong passwords**
   - Minimum 16 characters
   - Mix of letters, numbers, and special characters

3. **Limit database permissions**
   - Create separate users for different environments
   - Grant only necessary privileges

4. **Enable SSL/TLS**
   - Use encrypted connections in production
   - Add `?ssl=true&sslmode=require` to JDBC URL

## Database Schema

The application uses Hibernate to automatically manage the database schema. The following table is created:

### barcode_items

| Column | Type | Constraints |
|--------|------|-------------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT |
| name | VARCHAR(255) | NOT NULL, UNIQUE |
| data | VARCHAR(255) | NOT NULL |

## Configuration

### Application Properties

The backend is configured in `apps/backend/src/main/resources/application.properties`:

```properties
# Database Configuration (uses environment variables)
spring.datasource.url=${DATABASE_URL:jdbc:postgresql://localhost:5432/barcode}
spring.datasource.username=${DATABASE_USERNAME:postgres}
spring.datasource.password=${DATABASE_PASSWORD:postgres}
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA/Hibernate Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.properties.hibernate.format_sql=true
```

### DDL Auto Modes

- `update` (default): Updates schema automatically, good for development
- `validate`: Only validates schema, good for production
- `create`: Drops and creates schema on startup (WARNING: loses data!)
- `create-drop`: Like create, but drops on shutdown
- `none`: No schema management

For production, consider using `validate` and managing schema migrations with tools like Flyway or Liquibase.

## Troubleshooting

### Connection Refused

- Verify PostgreSQL is running: `sudo systemctl status postgresql` (Linux) or `brew services list` (macOS)
- Check PostgreSQL is listening on 5432: `netstat -an | grep 5432`
- Verify host and port in connection URL

### Authentication Failed

- Verify username and password
- Check `pg_hba.conf` for authentication settings
- Ensure user has correct privileges

### Schema Not Created

- Check `spring.jpa.hibernate.ddl-auto` is set to `update` or `create`
- Verify database user has CREATE TABLE privileges
- Check logs for Hibernate errors

## Testing

The integration tests use an in-memory H2 database, so they don't require PostgreSQL to be installed.

```bash
# Run all tests
mvn test

# Run specific test
mvn test -Dtest=BarcodeIntegrationTest
```
