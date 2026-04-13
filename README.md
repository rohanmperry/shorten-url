# shorten-url

Serverless URL shortener built on AWS — API Gateway, Lambda, DynamoDB, inside a VPC.

- 100% Terraform.
- make plan - to check the plan
- make appy - to deploy
- make destroy - to destroy

## Usage
```bash
# First get the AWS API Gateway end-point.
#
API_ENDPOINT=$(AWS_PROFILE=<your AWS local profile> terraform -chdir=terraform output -raw api_endpoint)

# Shorten a URL
curl -X POST /shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/<long URL>"}'

## Requirements

- Terraform >= 1.7
- AWS CLI configured with a named profile
- Python >= 3.11 (for Lambda and tests)
