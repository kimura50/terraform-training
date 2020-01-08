resource "aws_iam_instance_profile" "ec2-access-role-profile" {
    name = "ec2-access-role-profile"
    role = aws_iam_role.ec2-access-role.name
}

resource "aws_iam_role" "ec2-access-role" {
    name = "ec2-access-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement" : [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ec2-s3-access-role-policy" {
    name = "ec2-s3-access-role-policy"
    role = aws_iam_role.ec2-access-role.id
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement" : [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "db-monitor" {
    name = "db-monitor"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "monitoring.rds.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "db-monitor" {
  role       = aws_iam_role.db-monitor.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}