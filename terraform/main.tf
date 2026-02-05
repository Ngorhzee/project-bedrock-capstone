module "compute" {
    source = "./compute"
    
  
}

module "networking" {
  source = "./networking"
   aws_region = var.aws_region
}

module "eks" {
    source = "./eks"
    private_subnets_id = module.networking.private_subnets_id
  
}