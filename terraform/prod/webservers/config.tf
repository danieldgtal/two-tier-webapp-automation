terraform {
  backend "s3" {
    bucket = "acsproject-prod"                   // Bucket from where to GET Terraform State
    key    = "prod/webservers/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                        // Region where bucket created
  }
}
