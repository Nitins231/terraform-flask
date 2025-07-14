🚀 Flask & Express Deployment on Separate EC2 Instances (Terraform on AWS)
📌 Overview
This project provisions two separate EC2 instances using Terraform:

One for the Flask backend

One for the Express frontend

Both applications are deployed with custom user data scripts and run on different ports. Communication between them is enabled via a private network inside a custom VPC.

🧾 File Structure
css
Copy
Edit
.
├── main.tf
├── variable.tf
├── output.tf
├── backend.tf
├── userdata-flask.sh
├── userdata-express.sh.tpl
⚙️ Prerequisites
AWS Account with programmatic access

EC2 Key Pair (Nitin-s) created in the AWS console

S3 bucket and DynamoDB table for Terraform backend (replace in backend.tf)

Terraform CLI installed

📁 Terraform Backend Configuration
backend.tf

hcl
Copy
Edit
terraform {
  backend "s3" {
    bucket         = "your-unique-terraform-bucket-name"
    key            = "separate-ec2-deployment/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"
  }
}
Make sure the S3 bucket and DynamoDB table exist before running terraform init.