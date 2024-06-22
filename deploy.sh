#!/bin/bash
set -e


# Package and deploy Lambda functions
zip -r lambda/register_user.zip src/lambda_functions/register_user.py
zip -r lambda/send_message.zip src/lambda_functions/send_message.py
zip -r lambda/check_messages.zip src/lambda_functions/check_messages.py
zip -r lambda/block_user.zip src/lambda_functions/block_user.py
zip -r lambda/create_group.zip src/lambda_functions/create_group.py
zip -r lambda/modify_group_members.zip src/lambda_functions/modify_group_members.py
zip -r lambda/send_group_message.zip src/lambda_functions/send_group_message.py

aws lambda update-function-code --function-name register_user --zip-file fileb://lambda/register_user.zip
aws lambda update-function-code --function-name send_message --zip-file fileb://lambda/send_message.zip
aws lambda update-function-code --function-name check_messages --zip-file fileb://lambda/check_messages.zip
aws lambda update-function-code --function-name block_user --zip-file fileb://lambda/block_user.zip
aws lambda update-function-code --function-name create_group --zip-file fileb://lambda/create_group.zip
aws lambda update-function-code --function-name modify_group_members --zip-file fileb://lambda/modify_group_members.zip
aws lambda update-function-code --function-name send_group_message --zip-file fileb://lambda/send_group_message.zip

# Output the API endpoint
aws apigateway get-rest-apis

# Initialize Terraform
terraform -chdir=terraform init

# Apply Terraform configuration
terraform -chdir=terraform apply -auto-approve