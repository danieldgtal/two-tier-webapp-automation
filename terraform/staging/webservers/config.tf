terraform {
  backend "s3" {
    bucket = "acsproject-staging"                   // Bucket from where to GET Terraform State
    key    = "staging/webservers/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                        // Region where bucket created
  }
}
