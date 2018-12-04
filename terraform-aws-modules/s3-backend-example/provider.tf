provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

# create an s3 bucket
resource "aws_s3_bucket" "terraform-state-file" {
  bucket = "${var.env}-${var.bucket_name}"
  versioning {enabled = true}
  tags {Name = "S3 Remote Bucket for Terraform State Store"}
}

terraform {
  backend "s3" {
    region = "us-east-1"
    encrypt = true
    bucket = "dev-lfe-tfstate-store"
    key = "dev/terraform/dev-lfe-state.tfstate"
  }
}