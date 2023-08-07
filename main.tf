module "base_network" {
  source                                      = "cn-terraform/networking/aws"
  name_prefix                                 = "tdrs-networking"
  vpc_cidr_block                              = "192.168.0.0/16"
  availability_zones                          = ["us-east-1a", "us-east-1b"]
  public_subnets_cidrs_per_availability_zone  = ["192.168.0.0/19", "192.168.32.0/19"]
  private_subnets_cidrs_per_availability_zone = ["192.168.128.0/19", "192.168.160.0/19"]
}

data "aws_ami" "docker_server" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["591542846629"] # AWS owned base image
}

resource "aws_key_pair" "deployer" {
  key_name   = "ghudson-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIABBSCcG4FJGtD10oSLLqGP5vO9evbzw/ijUXgz5hkW8 georgehudson78@gmail.com"
}