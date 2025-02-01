module "k8s_cluster_create" {
    source = "./modules/k8s"

    cluster_name = var.cluster_name
    project_id = var.project_id
    region = var.region
    network = var.network
    subnet = var.subnet
}