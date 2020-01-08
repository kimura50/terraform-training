resource "aws_iam_instance_profile" "web-profile" {
  name = "web-profile"
  role = aws_iam_role.cloud-watch-agent-server-role.name
}

resource "aws_iam_role" "cloud-watch-agent-server-role" {
    name = "CloudWatchAgentServerRole"
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

resource "aws_iam_role_policy_attachment" "cloud-watch-agent-server-role-attach" {
    role = aws_iam_role.cloud-watch-agent-server-role.name
    policy_arn = data.aws_iam_policy.cloud-watch-agent-server-policy.arn
}

data "aws_iam_policy" "cloud-watch-agent-server-policy" {
    arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}