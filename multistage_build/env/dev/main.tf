provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.region
}

data "terraform_remote_state" "bastion" {
    backend = "s3"
    config = {
        bucket = var.remote_state_bucket
        region = "ap-northeast-1"
        key = "terraform.tfstate"
    }
}

module "vpc_env" {
    source = "../../module/vpc_env"
    
    myVPC-id = data.terraform_remote_state.bastion.outputs.myVPC-id
    myGW-id = data.terraform_remote_state.bastion.outputs.myGW-id
    public-route-id = data.terraform_remote_state.bastion.outputs.public-route-id
}

module "s3" {
    source = "../../module/s3"    
}

module "iam" {
    source = "../../module/iam"
}

module "sg" {
    source = "../../module/sg"

    myVPC-id = data.terraform_remote_state.bastion.outputs.myVPC-id
    sg-bastion-id = data.terraform_remote_state.bastion.outputs.sg-bastion-id 
}

module "elb" {
    source = "../../module/elb"

    myVPC-id = data.terraform_remote_state.bastion.outputs.myVPC-id
    sg-web-id = module.sg.sg-web-id
    subnet-public-a-id = module.vpc_env.subnet-public-a-id
    subnet-public-c-id = module.vpc_env.subnet-public-c-id
    kimura-example-access-log-bucket = module.s3.kimura-example-access-log-bucket
}

module "ec2" {
    source = "../../module/ec2"

    sg-web-id = module.sg.sg-web-id
    subnet-public-a-id = module.vpc_env.subnet-public-a-id
    subnet-public-c-id = module.vpc_env.subnet-public-c-id
    subnet-private-a-id = module.vpc_env.subnet-private-a-id
    subnet-private-c-id = module.vpc_env.subnet-private-c-id
    alb-web-target-group-arn = module.elb.alb-web-target-group-arn
    web-profile-name = module.iam.web-profile-name
}
