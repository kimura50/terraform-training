resource "aws_s3_bucket" "kimura-example-access-log-bucket" {
    bucket = "kimura-example-access-log-bucket"
    acl = "log-delivery-write"
}