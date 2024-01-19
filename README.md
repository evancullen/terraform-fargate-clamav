terraform-fargate-clamav
Repository for an article on scanning files with Terraform, Lambda, Fargate, Docker, S3, SQS, and ClamAV.

Initialization
Run the tf-setup.sh script to set up the S3 bucket and DynamoDB lock table for terraform.
terraform init
terraform apply
Testing
For testing both the valid and virus files, run ./test-virus.sh