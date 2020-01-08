variable "sg-bastion-id" {}
variable "bastion-subnet-public-a-id" {}

data aws_ssm_parameter amzn2_ami {
    name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

locals {
    userdata = <<USERDATA
#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo yum -y update
sudo yum install -y mysql
sudo amazon-linux-extras install ansible2
sudo yum install -y docker
sudo yum install -y httpd
sudo systemctl enable httpd
USERDATA
}