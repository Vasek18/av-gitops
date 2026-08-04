terraform {
  cloud {
    organization = "aristovvasiliy"

    workspaces {
      name = "av-gitops-cluster"
    }
  }
}
