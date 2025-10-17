# OVH Cloud Architecture

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Internet / Users                          │
└───────────────────────┬──────────────────┬──────────────────────┘
                        │                  │
                        │                  │
                   ┌────▼────┐        ┌────▼────┐
                   │ Frontend│        │ Backend │
                   │   CDN   │        │   API   │
                   │ (S3/CDN)│        │   LB    │
                   └─────────┘        └────┬────┘
                                           │
┌──────────────────────────────────────────┼──────────────────────┐
│                 OVH Cloud Infrastructure  │                      │
│                                          │                      │
│  ┌───────────────────────────────────────▼────────────────┐    │
│  │         Private Network (vRack)                         │    │
│  │                  10.0.0.0/16                            │    │
│  │                                                         │    │
│  │  ┌──────────────────────────────────────────────────┐  │    │
│  │  │      Managed Kubernetes Cluster                  │  │    │
│  │  │                                                  │  │    │
│  │  │  ┌─────────────────────────────────────────┐    │  │    │
│  │  │  │  Namespace: barcode-backend             │    │  │    │
│  │  │  │                                         │    │  │    │
│  │  │  │  ┌──────────┐  ┌──────────┐           │    │  │    │
│  │  │  │  │ Backend  │  │ Backend  │           │    │  │    │
│  │  │  │  │  Pod 1   │  │  Pod 2   │  (Auto-   │    │  │    │
│  │  │  │  │          │  │          │   scale)  │    │  │    │
│  │  │  │  └─────┬────┘  └─────┬────┘           │    │  │    │
│  │  │  │        │              │                │    │  │    │
│  │  │  │        └──────┬───────┘                │    │  │    │
│  │  │  │               │                        │    │  │    │
│  │  │  │        ┌──────▼──────┐                 │    │  │    │
│  │  │  │        │   Service   │                 │    │  │    │
│  │  │  │        │ LoadBalancer│                 │    │  │    │
│  │  │  │        └─────────────┘                 │    │  │    │
│  │  │  │                                         │    │  │    │
│  │  │  │  ┌─────────────────────────────────┐   │    │  │    │
│  │  │  │  │  Secrets                        │   │    │  │    │
│  │  │  │  │  - DATABASE_URL                 │   │    │  │    │
│  │  │  │  │  - DATABASE_USERNAME            │   │    │  │    │
│  │  │  │  │  - DATABASE_PASSWORD            │   │    │  │    │
│  │  │  │  └─────────────────────────────────┘   │    │  │    │
│  │  │  └─────────────────────────────────────────┘    │  │    │
│  │  │                                                  │  │    │
│  │  │  Node Pool (b2-7)                                │  │    │
│  │  │  - Min: 1 node                                   │  │    │
│  │  │  - Max: 5 nodes                                  │  │    │
│  │  │  - Autoscaling: Enabled                          │  │    │
│  │  └──────────────────────────────────────────────────┘  │    │
│  │                                    │                    │    │
│  │                                    │                    │    │
│  │  ┌─────────────────────────────────▼──────────────┐    │    │
│  │  │      Managed PostgreSQL Database               │    │    │
│  │  │                                                │    │    │
│  │  │  Plan: Essential / Business                    │    │    │
│  │  │  Version: PostgreSQL 15                        │    │    │
│  │  │                                                │    │    │
│  │  │  Database: barcode                             │    │    │
│  │  │  User: barcode_user                            │    │    │
│  │  │                                                │    │    │
│  │  │  IP Restrictions:                              │    │    │
│  │  │    - Kubernetes Subnet Only                    │    │    │
│  │  │                                                │    │    │
│  │  │  Backups: Automatic                            │    │    │
│  │  └────────────────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │      Object Storage (S3-Compatible)                      │  │
│  │                                                          │  │
│  │  Bucket: barcode-frontend                                │  │
│  │  - index.html                                            │  │
│  │  - static/*                                              │  │
│  │  - assets/*                                              │  │
│  │  - manifest.json                                         │  │
│  │                                                          │  │
│  │  Access: Public Read                                     │  │
│  │  CDN: Optional                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │      Container Registry                                  │  │
│  │                                                          │  │
│  │  Images:                                                 │  │
│  │  - barcode-backend:latest                                │  │
│  │  - barcode-backend:main-abc1234                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Component Details

### Frontend Layer
- **Technology**: React PWA (Progressive Web App)
- **Storage**: OVH Object Storage (S3-compatible)
- **Delivery**: Direct access or via CDN (optional)
- **Files**: Static HTML, CSS, JavaScript, assets

### Backend Layer
- **Technology**: Java Spring Boot
- **Container**: Docker image on GitHub Container Registry
- **Orchestration**: Kubernetes with auto-scaling
- **Replicas**: 2-5 pods (configurable)
- **Resources**: 
  - Requests: 250m CPU, 512Mi memory
  - Limits: 1000m CPU, 1Gi memory

### Database Layer
- **Type**: Managed PostgreSQL
- **Version**: 15
- **Plan**: Essential (dev/test) or Business (production)
- **Features**:
  - Automatic backups
  - High availability (Business plan)
  - Monitoring and metrics
  - IP-based access control

### Network Layer
- **Private Network**: vRack-based isolation
- **CIDR**: 10.0.0.0/16
- **Security**:
  - Database accessible only from K8s subnet
  - Frontend served via HTTPS (if CDN enabled)
  - Backend exposed via LoadBalancer

## Data Flow

### 1. User Access Frontend
```
User → Browser → Object Storage (S3) → React App Loads
```

### 2. Frontend Calls Backend API
```
React App → HTTP Request → LoadBalancer → Backend Pod
```

### 3. Backend Accesses Database
```
Backend Pod → Private Network → PostgreSQL → Data
```

### 4. Response Flow
```
PostgreSQL → Backend Pod → LoadBalancer → React App → User
```

## Security Architecture

### Network Security
```
┌─────────────────────────────────────────┐
│ Internet                                │
│ ↓ (HTTPS - if CDN enabled)              │
│ Frontend (Public)                       │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Internet                                │
│ ↓ (HTTP/HTTPS via LoadBalancer)        │
│ Backend API (Public)                    │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Private Network Only                    │
│ Backend Pods ↔ PostgreSQL               │
│ (IP Restricted to 10.0.0.0/16)         │
└─────────────────────────────────────────┘
```

### Secrets Management
```
OVH API Credentials
       ↓
Terraform Variables
       ↓
Kubernetes Secrets
       ↓
Environment Variables in Pods
```

## Scalability

### Horizontal Scaling (Automatic)
```
Traffic Increase
       ↓
Kubernetes Metrics Server
       ↓
Horizontal Pod Autoscaler
       ↓
New Pods Created (up to max_nodes)
```

### Vertical Scaling (Manual)
```
Update terraform.tfvars
    - node_flavor (e.g., b2-7 → b2-15)
    - db_plan (essential → business)
       ↓
terraform apply
       ↓
Resources Upgraded
```

## High Availability

### Backend
- **Multiple Pods**: 2+ replicas across nodes
- **Health Checks**: Liveness and readiness probes
- **Auto-restart**: Kubernetes restarts failed pods
- **Load Balancing**: Traffic distributed across pods

### Database
- **Managed Service**: OVH handles HA
- **Business Plan**: Multi-node cluster
- **Automatic Backups**: Point-in-time recovery
- **Monitoring**: Built-in alerting

### Frontend
- **Object Storage**: Highly available by design
- **CDN** (optional): Global distribution
- **Static Files**: No downtime for updates

## Disaster Recovery

### Backup Strategy
```
Database
  ├─ Automatic daily backups (OVH)
  ├─ Point-in-time recovery
  └─ Backup retention: 7-30 days

Frontend
  ├─ Source code in Git
  ├─ Build reproducible from code
  └─ Quick redeployment

Kubernetes
  ├─ Terraform state (infrastructure)
  ├─ Deployment configs in Git
  └─ Container images in registry
```

### Recovery Procedures
```
1. Infrastructure Loss
   → terraform apply (rebuild from code)

2. Database Corruption
   → Restore from OVH backup

3. Backend Failure
   → Kubernetes auto-restarts
   → Deploy new version if needed

4. Frontend Loss
   → Rebuild and redeploy (5 minutes)
```

## Monitoring & Observability

### Metrics
- **Kubernetes**: Built-in metrics server
- **Database**: OVH console metrics
- **Backend**: Health endpoint `/barcodes/health`

### Logs
```bash
# Backend logs
kubectl logs -n barcode-backend -l app=barcode-backend

# Pod events
kubectl get events -n barcode-backend

# Database logs
OVH Control Panel → Database → Logs
```

## Cost Breakdown

### Fixed Costs (Monthly)
| Component | Size | Cost |
|-----------|------|------|
| Kubernetes (2 nodes) | b2-7 | €35-45 |
| PostgreSQL | Essential | €15-20 |
| Container Registry | Small | €3-5 |
| **Subtotal** | | **€53-70** |

### Variable Costs
| Component | Rate | Est. Cost |
|-----------|------|-----------|
| Object Storage | €0.01/GB | €0.10 |
| Network Transfer | €0.01/GB | €1-5 |
| CDN (optional) | €0.01/GB | €2-10 |

### Total Estimated Cost
- **Development**: €55-65/month
- **Production**: €70-85/month

## Performance Characteristics

### Response Times
- **Frontend Load**: < 2s (first load), < 500ms (cached)
- **API Response**: < 100ms (typical)
- **Database Query**: < 50ms (indexed queries)

### Throughput
- **Backend**: ~100 req/s per pod (scalable)
- **Database**: 500-1000 connections (plan dependent)
- **Object Storage**: Unlimited reads

### Scaling Limits
- **Min**: 1 node, 1 pod
- **Max**: 5 nodes, 20+ pods (configurable)
- **Auto-scale**: Based on CPU/memory metrics
