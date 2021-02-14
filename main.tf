provider "aws" {
    region = "us-east-2"
    access_key = "<Enter ACEES KEy>"
    secret_key ="<Enter Secret KEY>"
}
# Query all avilable Availibility Zone
data "aws_availability_zones" "available" {}

module "vpc" {
  source = "./vpcmodule"
  vpc_cidr = "10.0.0.0/16"
  public_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}



# module "ec2module" {
#   source = "./ec2module"
#   instance_type = "t2.micro"
#   security_group = module.vpc.sec1_group
#   subnets = module.vpc.subnets
# }


module "alb" {
  source = "./alb"
  vpc_id = module.vpc.vpc_id
  #instance1_id = module.ec2module.instance1_id
  #instance2_id = module.ec2module.instance2_id
  subnet1 = module.vpc.subnet1
  subnet2 = module.vpc.subnet2
  depends_on = [module.db]
}

module "db" {

  source = "./mysql"
  vpc_id = module.vpc.vpc_id
  #instance1_id = module.ec2module.instance1_id
  #instance2_id = module.ec2module.instance2_id
  rds_subnet1 = module.vpc.private_subnet1
  rds_subnet2 = module.vpc.private_subnet2
  db_instance = "db.t2.micro"
  
}
