# Reference
# https://github.com/pulumi/examples/blob/master/gcp-py-gke/__main__.py

import os
from pathlib import Path
from pulumi import Config, export, get_project, get_stack, Output, ResourceOptions
from pulumi_gcp.config import project, zone, region
from pulumi_gcp.container import Cluster, get_engine_versions, NodePool
from pulumi_kubernetes import Provider
from pulumi_kubernetes.apps.v1 import Deployment
from pulumi_kubernetes.core.v1 import Service
from pulumi_random import RandomPassword

# Read in some configurable settings for our cluster:
config = Config(None)

NODE_COUNT = config.get("node_count")
NODE_MACHINE_TYPE = config.get("node_machine_type")
IMAGE_TYPE = config.get("image_type")
DISK_TYPE = config.get("disk_type")
DISK_SIZE_GB = config.get("disk_size_gb")

# master version of GKE engine
ENGINE_VERSION = get_engine_versions().latest_master_version
CLUSTER_NAME = config.get("cluster_name")
NODE_POOL_NAME = f"{CLUSTER_NAME}-node-pool"

print(f"Engine version: {ENGINE_VERSION}")
print(f"Project: {project} | Region: {region} | Zone: {zone}")

# Now, actually create the GKE cluster.
k8s_cluster = Cluster(
    resource_name=CLUSTER_NAME,
    initial_node_count=1,
    location=zone,
    min_master_version=ENGINE_VERSION,
    node_version=ENGINE_VERSION,
    node_config={
        "machine_type": NODE_MACHINE_TYPE,
        "imageType": IMAGE_TYPE,
        "diskType": DISK_TYPE,
        "disk_size_gb": DISK_SIZE_GB,
        "oauth_scopes": [
            "https://www.googleapis.com/auth/compute",
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ],
    }
)

node_pool = NodePool(
    resource_name=NODE_POOL_NAME,
    cluster=k8s_cluster.name,
    initial_node_count=1,
    location=zone,
    node_config={
        "machine_type": NODE_MACHINE_TYPE,
        "imageType": IMAGE_TYPE,
        "diskType": DISK_TYPE,
        "disk_size_gb": DISK_SIZE_GB,
        "oauth_scopes": [
            "https://www.googleapis.com/auth/cloud-platform",
        ],
    })

# Manufacture a GKE-style Kubeconfig. Note that this is slightly "different" because of the way GKE requires
# gcloud to be in the picture for cluster authentication (rather than using the client cert/key directly).
# Export the Cluster name
export("cluster_name", k8s_cluster.name)

# Manufacture a GKE-style kubeconfig
kubeconfig = Output.all(k8s_cluster.name, k8s_cluster.endpoint, k8s_cluster.master_auth).apply(
    lambda args: f"""
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: {k8s_cluster.master_auth.cluster_ca_certificate}
        server: https://{args[1]}
      name: {args[0]}
    contexts:
    - context:
        cluster: {args[0]}
        user: {args[0]}
      name: {args[0]}
    current-context: {args[0]}
    kind: Config
    preferences: {{}}
    users:
    - name: {args[0]}
      user:
        exec:
          apiVersion: client.authentication.k8s.io/v1beta1
          command: gke-gcloud-auth-plugin
          installHint: Install gke-gcloud-auth-plugin for use with kubectl by following
            https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
          provideClusterInfo: true
    """
)

export("kubeconfig", kubeconfig)

# Write kubeconfig to file
def write_kubeconfig(content):
    kubeconfig_path = Path(os.path.expanduser(f"~/.kube"))
    filename = Path(os.path.expanduser(f"~/.kube/config"))
    kubeconfig_path.mkdir(parents=True, exist_ok=True)    
    filename.touch(exist_ok=True)
    with open(filename, "w") as file:
        file.write(content)
        
kubeconfig.apply(lambda content: write_kubeconfig(content))

# Create a Kubernetes provider instance that uses our cluster from above
# from pulumi_kubernetes import Provider
# cluster_provider = Provider("helloworld-provider", kubeconfig=kubeconfig)

# Create a canary deployment to test that this cluster works.
# labels = {"app": "canary-{0}-{1}".format(get_project(), get_stack())}
# canary = Deployment(
#     "canary",
#     spec={
#         "selector": {"matchLabels": labels},
#         "replicas": 1,
#         "template": {
#             "metadata": {"labels": labels},
#             "spec": {"containers": [{"name": "nginx", "image": "nginx"}]},
#         },
#     },
#     __opts__=ResourceOptions(provider=k8s_provider),
# )

# ingress = Service(
#     "ingress",
#     spec={"type": "LoadBalancer", "selector": labels, "ports": [{"port": 80}]},
#     __opts__=ResourceOptions(provider=k8s_provider),
# )

# Finally, export the kubeconfig so that the client can easily access the cluster.
export("kubeconfig", kubeconfig)
# Export the k8s ingress IP to access the canary deployment
# export("ingress_ip", Output.all(ingress.status["load_balancer"]["ingress"][0]["ip"]))