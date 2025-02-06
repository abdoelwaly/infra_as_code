module "network" {
  source     = "./modules/network"
  cidr_block = "10.0.0.0/16"
  name       = "main"
}

module "security" {
  source     = "./modules/security"
  vpc_id     = module.network.vpc_id
}

module "compute" {
  source          = "./modules/compute"
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets
  public_sg_id    = module.security.public_sg_id
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = module.compute.private_key_path
}