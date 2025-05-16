#!/bin/bash

# Navigate to the directory containing this script
cd "$(dirname "$0")"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Terraform is not installed. Please install it from https://www.terraform.io/downloads"
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "Creating example tfvars file..."
    cp terraform.tfvars.example terraform.tfvars
    echo "Please edit terraform.tfvars with your actual credentials before running this script again."
    exit 1
fi

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Create workspace plan
echo "Creating deployment plan..."
terraform plan -out=tfplan

# Ask for confirmation before applying
echo ""
echo "Review the plan above. Do you want to apply this plan? (y/n)"
read -r answer
if [ "$answer" != "y" ]; then
    echo "Deployment cancelled."
    exit 0
fi

# Apply the Terraform plan
echo "Applying Terraform plan..."
terraform apply tfplan

echo "Deployment completed!" 