module "kube_hetzner" {
  source  = "kube-hetzner/kube-hetzner/hcloud"
  version = "3.0.1"

  providers = {
    hcloud = hcloud
  }

  hcloud_token = var.hcloud_token

  cluster_name   = "av-gitops"
  network_region = "eu-central" # Hetzner network region covering fsn1/nbg1/hel1

  ssh_public_key  = var.ssh_public_key
  ssh_private_key = var.ssh_private_key

  control_plane_nodepools = [
    {
      name        = "control-plane-hel1"
      server_type = "cx23"
      location    = "hel1"
      labels      = []
      taints      = []
      count       = 1
    }
  ]

  agent_nodepools = [
    {
      name        = "agent-hel1"
      server_type = "cx23"
      location    = "hel1"
      labels      = []
      taints      = []
      count       = 1
    }
  ]

  # No built-in ingress controller: ArgoCD installs and manages ingress-nginx and
  # cert-manager itself once bootstrapped (see docs/plan.md, platform/ layer). With
  # ingress_controller = "none" the module does not provision an ingress load
  # balancer either — the Hetzner CCM (enabled by default by this module) creates
  # one dynamically once ArgoCD deploys ingress-nginx as a LoadBalancer Service.
  ingress_controller  = "none"
  enable_cert_manager = false

  # Don't write a local kubeconfig file during apply; CI has no use for it and it
  # would otherwise land in the workspace unencrypted. Fetch it on demand instead
  # with `terraform output -raw kubeconfig` (see docs/plan.md).
  create_kubeconfig = false
}
