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
curl -X POST $API_ENDPOINT/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "<long URL>"}'

# It should display the short URL.
# You can copy and paste the short URL into a browser.
# The application will find the original URL and
# send a redirect to that.

## Requirements

- Terraform >= 1.14
- AWS CLI configured with a named local profile
- Python >= 3.11 (for Lambda and tests)
