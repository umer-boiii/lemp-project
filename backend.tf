terraform {
  backend "s3" {
    bucket  = "php-info-page" 
    key     = "lemp-pipeline/terraform.tfstate"
    region  = "eu-north-1"
    encrypt = true
  }
}