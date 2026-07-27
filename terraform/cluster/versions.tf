terraform {
  required_version = ">= 1.10.1, < 1.11.2"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.62.0"
    }
  }
}
