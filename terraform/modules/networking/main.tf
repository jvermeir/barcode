# Networking module for OVH Cloud

# Create private network (vRack)
resource "ovh_cloud_project_network_private" "network" {
  service_name = var.project_id
  name         = "${var.environment}-${var.network_name}"
  regions      = [var.region]
  vlan_id      = var.vlan_id
}

# Create subnet for the private network
resource "ovh_cloud_project_network_private_subnet" "subnet" {
  service_name = var.project_id
  network_id   = ovh_cloud_project_network_private.network.id
  region       = var.region
  
  # Subnet configuration
  start        = cidrhost(var.subnet_cidr, 1)
  end          = cidrhost(var.subnet_cidr, 254)
  network      = var.subnet_cidr
  dhcp         = true
  no_gateway   = false
}

# Security group for backend services
resource "ovh_cloud_project_kube_nodepool" "backend_nodepool" {
  service_name = var.project_id
  kube_id      = var.kube_id
  name         = "${var.environment}-backend-pool"
  
  # Node configuration
  flavor_name  = var.node_flavor
  desired_nodes = var.desired_nodes
  min_nodes    = var.min_nodes
  max_nodes    = var.max_nodes
  
  monthly_billed = false
  anti_affinity  = false
  autoscale      = true
}
