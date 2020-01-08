output "myVPC-id" {
  value = module.vpc_base.myVPC-id
}

output "myGW-id" {
  value = module.vpc_base.myGW-id 
}

output "public-route-id" {
  value = module.vpc_base.public-route-id
}

output "sg-bastion-id" {
  value = module.sg_bastion.sg-bastion-id
}