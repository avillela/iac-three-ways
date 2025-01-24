from pulumi import Config, export, get_project, get_stack, Output, ResourceOptions
from pulumi_gcp.config import project, zone, region
from pulumi_gcp.container import Cluster, get_engine_versions
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
MASTER_VERSION = config.get("master_version")
CLUSTER_NAME = config.get("pulumi-gke")

print(f"Master version: {MASTER_VERSION}")
print(f"Project: {project} | Region: {region} | Zone: {zone}")

# Now, actually create the GKE cluster.
# Pulumi docs: https://www.pulumi.com/docs/reference/pkg/python/pulumi_gcp/container/#pulumi_gcp.container.Cluster
# Terraform docs: https://www.terraform.io/docs/providers/google/r/container_cluster.html
k8s_cluster = Cluster(
    "gke-cluster",
    name=CLUSTER_NAME,
    # Zone is read automagically from the stack config file
    # Cluster version
    min_master_version=MASTER_VERSION,
    master_auth={
        # Pulumi requires one of clientCertificateConfig, password, or username. If
        # Username is not present, then basic auth is disabled.
        # See docs (master_auth): https://github.com/pulumi/pulumi-gcp/blob/master/sdk/python/pulumi_gcp/container/cluster.py
        # This is the equivalent of --no-enable-basic-auth
        "password": ""
    },
    # Networking
    network=f"projects/{project}/global/networks/opsnet",
    subnetwork=f"projects/{project}/regions/{region}/subnetworks/opsnet",
    ip_allocation_policy={
        # This empty dict enables IP aliasing (equivalent of --enable-ip-alias)
    },
    default_max_pods_per_node="110",
    node_pools=[
        {
            "initial_node_count": NODE_COUNT,
            "management": {"autoRepair": True, "autoUpgrade": True},
            "node_config": {
                "machine_type": NODE_MACHINE_TYPE,
                "imageType": IMAGE_TYPE,
                "diskType": DISK_TYPE,
                "disk_size_gb": DISK_SIZE_GB,
                "oauth_scopes": [
                    "https://www.googleapis.com/auth/devstorage.read_only",
                    "https://www.googleapis.com/auth/logging.write",
                    "https://www.googleapis.com/auth/monitoring",
                    "https://www.googleapis.com/auth/servicecontrol",
                    "https://www.googleapis.com/auth/service.management.readonly",
                    "https://www.googleapis.com/auth/trace.append",
                ],
            },
        }
    ],
    addons_config={
        # These are enabled by default. Don't need them.
        "horizontalPodAutoscaling": {"disabled": "false"},
        # "httpLoadBalancing": {"disabled": False},
        "istioConfig": {"disabled": False, "auth": "AUTH_MUTUAL_TLS"},
    },
    # Equivalent of --no-enable-stackdriver-kubernetes
    logging_service=None,
)

# Manufacture a GKE-style Kubeconfig. Note that this is slightly "different" because of the way GKE requires
# gcloud to be in the picture for cluster authentication (rather than using the client cert/key directly).
k8s_info = Output.all(k8s_cluster.name, k8s_cluster.endpoint, k8s_cluster.master_auth)
k8s_config = k8s_info.apply(
    lambda info: """apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: {0}
    server: https://{1}
  name: {2}
contexts:
- context:
    cluster: {2}
    user: {2}
  name: {2}
current-context: {2}
kind: Config
preferences: {{}}
users:
- name: {2}
  user:
    auth-provider:
      config:
        cmd-args: config config-helper --format=json
        cmd-path: gcloud
        expiry-key: '{{.credential.token_expiry}}'
        token-key: '{{.credential.access_token}}'
      name: gcp
""".format(
        info[2]["clusterCaCertificate"],
        info[1],
        "{0}_{1}_{2}".format(project, zone, info[0]),
    )
)

# Make a Kubernetes provider instance that uses our cluster from above.
k8s_provider = Provider("gke_k8s", kubeconfig=k8s_config)

# Create a canary deployment to test that this cluster works.
labels = {"app": "canary-{0}-{1}".format(get_project(), get_stack())}
canary = Deployment(
    "canary",
    spec={
        "selector": {"matchLabels": labels},
        "replicas": 1,
        "template": {
            "metadata": {"labels": labels},
            "spec": {"containers": [{"name": "nginx", "image": "nginx"}]},
        },
    },
    __opts__=ResourceOptions(provider=k8s_provider),
)

ingress = Service(
    "ingress",
    spec={"type": "LoadBalancer", "selector": labels, "ports": [{"port": 80}]},
    __opts__=ResourceOptions(provider=k8s_provider),
)

# Finally, export the kubeconfig so that the client can easily access the cluster.
export("kubeconfig", k8s_config)
# Export the k8s ingress IP to access the canary deployment
export("ingress_ip", Output.all(ingress.status["load_balancer"]["ingress"][0]["ip"]))