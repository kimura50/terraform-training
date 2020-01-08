terraform {
    backend "s3" {
        bucket = "kimura.remote-state"
        region = "ap-northeast-1"
        key = "terraform.tfstate"
    }
}

provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.region
}

module "vpc_base" {
    source = "../../module/vpc_base"    
}

module "sg_bastion" {
    source = "../../module/sg_bastion"

    myVPC-id = module.vpc_base.myVPC-id
}

module "ec2_bastion" {
    source = "../../module/ec2_bastion"

    sg-bastion-id = module.sg_bastion.sg-bastion-id
    bastion-subnet-public-a-id = module.vpc_base.bastion-subnet-public-a-id
}
