provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "../../modules/network"
}
