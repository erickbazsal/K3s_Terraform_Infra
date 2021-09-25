#compute/locals
locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Terraform_Managed = "True"
    Owner             = "Erick.Bazan@gmail.com"
  }
}