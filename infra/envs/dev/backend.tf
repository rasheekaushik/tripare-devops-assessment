terraform {
  backend "local" {
    path = "terraform.tfstate.d/dev/terraform.tfstate"
  }
}
