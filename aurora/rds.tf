resource "aws_db_subnet_group" "dbsubnet" {
    name = "dbsubnet"
    subnet_ids = [aws_subnet.private-a.id, aws_subnet.private-c.id]
}

resource "aws_db_parameter_group" "db-parameter" {
    name = "db-parameter"
    family = "aurora5.6"
    description = "Aurora default"
}

# Auroraでは上記のparameter_group以外にCluster用パラメータが存在
resource "aws_rds_cluster_parameter_group" "cls-parameter" {
    name = "cls-parameter"
    family = "aurora5.6"
    description = "Aurora Cluster default"
}

# Aurora以外ではaws_db_instanceを利用
resource "aws_rds_cluster" "example-db-cls" {
    cluster_identifier = "example-db-cls"
    engine = "aurora"
    # 最終的にIAMロールを振ること
    master_username = "admin"
    master_password = "!adminpassword"
    backup_retention_period = 1
    preferred_backup_window = "07:00-09:00"
    vpc_security_group_ids = [
        aws_security_group.db.id
    ]
    db_subnet_group_name = aws_db_subnet_group.dbsubnet.name
    db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cls-parameter.name
    skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "example-db-cls-ins" {
    count = 2
    identifier = "example-db-cls-ins-${count.index}"
    cluster_identifier = aws_rds_cluster.example-db-cls.id
    instance_class = "db.t2.small"
    db_parameter_group_name = aws_db_parameter_group.db-parameter.name
}