# Production environment variables
# This file contains production-specific overrides

environment = "production"

# Scale up for production
backend_replicas = 3

# Use business plan for database in production
db_plan = "business"

# Enable CDN for frontend
enable_cdn = true
