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