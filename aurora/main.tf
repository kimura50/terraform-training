provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.region
}

locals {
    userdata = <<USERDATA
#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo yum -y update
sudo yum install -y mysql
sudo yum install -y httpd
sudo systemctl enable httpd
USERDATA
}