#!/bin/bash

# Exit on any error
set -e

# Display usage information
show_help() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help        Show this help message"
  echo "  -p, --plan        Only create plan but don't apply"
  echo "  -d, --destroy     Destroy the infrastructure"
  echo ""
}

# Parse command line arguments
PLAN_ONLY=false
DESTROY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -p|--plan)
      PLAN_ONLY=true
      shift
      ;;
    -d|--destroy)
      DESTROY=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

# Check if required files exist
if [ ! -f "terraform.tfvars" ]; then
  echo "Error: terraform.tfvars file not found."
  echo "Please create a terraform.tfvars file using the example in the README."
  exit 1
fi

if [ ! -f "secrets.tfvars" ]; then
  echo "Error: secrets.tfvars file not found."
  echo "Please copy secrets.tfvars.example to secrets.tfvars and edit it."
  exit 1
fi

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Define common var file options
VAR_FILES="-var-file=terraform.tfvars -var-file=secrets.tfvars"

# Handle different execution modes
if [ "$DESTROY" = true ]; then
  echo "Destroying infrastructure..."
  terraform destroy $VAR_FILES
elif [ "$PLAN_ONLY" = true ]; then
  echo "Creating plan only..."
  terraform plan $VAR_FILES -out=tfplan
else
  echo "Creating execution plan..."
  terraform plan $VAR_FILES -out=tfplan
  
  echo "Applying execution plan..."
  terraform apply tfplan
  
  echo "Deployment complete!"
fi 