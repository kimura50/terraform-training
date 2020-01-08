variable "sg-web-id" {}
variable "subnet-public-a-id" {}
variable "subnet-public-c-id" {}
variable "subnet-private-a-id" {}
variable "subnet-private-c-id" {}
variable "alb-web-target-group-arn" {}

variable "web-profile-name" {}


data aws_ssm_parameter amzn2_ami {
    name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

locals {
    userdata = <<USERDATA
#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo yum -y update
sudo yum install -y mysql
sudo yum install -y httpd
sudo systemctl enable httpd
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm
USERDATA
}