variable "hcloud_token" {
  description = "Hetzner Cloud API token (Read & Write). Injected via TF_VAR_hcloud_token in CI; never committed."
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Single-line OpenSSH public key for node access. Injected via TF_VAR_ssh_public_key in CI."
  type        = string
}

variable "ssh_private_key" {
  description = "SSH private key matching ssh_public_key. Injected via TF_VAR_ssh_private_key in CI; never committed."
  type        = string
  sensitive   = true
}
