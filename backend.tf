
terraform {
  backend "remote" {
    organization = "erickbazsal"

    workspaces {
      name = "dev"
    }
  }
}
