# Deploy k8s cluster and nodepool
module "k8s_cluster_create" {
    source = "./modules/k8s"

    project_id = var.project_id
    region = var.region
    zone = var.zone
    network = var.network
    subnet = var.subnet

    cluster_name = var.cluster_name
    disk_size_gb = var.disk_size_gb
    disk_type = var.disk_type
    image_type = var.image_type
    node_count = var.node_count
    node_machine_type = var.node_machine_type
}

# Canary deployment
module "canary_deployment" {
    source = "./modules/canary_deployment"
    depends_on = [module.k8s_cluster_create]

    project_id = var.project_id
    canary_deployment_namespace = var.canary_deployment_namespace

    cluster_name = var.cluster_name
    region = var.region
    network = var.network
    subnet = var.subnet
}