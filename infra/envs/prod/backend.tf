terraform {
  backend "local" {
    path = "terraform.tfstate.d/prod/terraform.tfstate"
  }
}
