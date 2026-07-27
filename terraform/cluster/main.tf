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

  # The control-plane API server and SSH are reachable from anywhere (module
  # defaults) — an accepted tradeoff for this architecture: the module
  # provisions nodes over SSH from wherever `terraform apply` runs (a
  # GitHub-hosted runner with unpredictable egress IPs), so a fixed
  # allowlist isn't practical yet. Revisit once there's a stable access path
  # (e.g. a static egress IP or a bastion).

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
  # load_balancer_location still matters even though no LB is created here: it's
  # baked into the CCM's own config and controls where the CCM places any LB it
  # creates later. Set to hel1 to match the cluster's location and avoid a
  # cross-datacenter hop once ingress-nginx exists.
  ingress_controller     = "none"
  enable_cert_manager    = false
  load_balancer_location = "hel1"

  # Pin to a k3s minor version explicitly (the module default of following the
  # "stable" channel would otherwise auto-upgrade Kubernetes without a
  # corresponding, reviewable Git change). automatically_upgrade_os is turned
  # off because this cluster has a single control-plane node: an unattended
  # OS upgrade reboots the only API server with no failover.
  k3s_channel              = "v1.33"
  automatically_upgrade_os = false

  # Don't write a local kubeconfig file during apply; CI has no use for it and it
  # would otherwise land in the workspace unencrypted. Fetch it on demand instead
  # with `terraform output -raw kubeconfig` (see docs/plan.md). create_kustomization
  # is disabled for the same reason — it would otherwise write an ungitignored
  # av-gitops_kustomization_backup.yaml on every apply.
  create_kubeconfig    = false
  create_kustomization = false
}
