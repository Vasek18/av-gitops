output "kubeconfig" {
  description = "Raw kubeconfig for the provisioned cluster. Fetch with: terraform output -raw kubeconfig > kubeconfig.yaml"
  value       = module.kube_hetzner.kubeconfig
  sensitive   = true
}

output "control_plane_ipv4" {
  description = "Public IPv4 addresses of the control-plane node(s) (for SSH debugging)."
  value       = module.kube_hetzner.control_planes_public_ipv4
}

output "agent_ipv4" {
  description = "Public IPv4 addresses of the worker node(s) (for SSH debugging)."
  value       = module.kube_hetzner.agents_public_ipv4
}
