# shorten-url

Serverless URL shortener built on AWS — API Gateway, Lambda, DynamoDB, inside a VPC.

## Architecture

- VPC with public and private subnets across 2 AZs
- Lambda functions running in private subnets
- DynamoDB accessed via VPC Gateway Endpoint (no NAT cost)
- API Gateway HTTP API as the public entry point
- 100% Terraform.
- make plan - to check the plan
- make appy - to deploy
- make destroy - to destroy

## Usage
```bash
# Deploy
make up

# Shorten a URL
curl -X POST /shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/long/path"}'

# Tear down
make down
```

## Requirements

- Terraform >= 1.7
- AWS CLI configured with a named profile
- Python >= 3.11 (for Lambda and tests)
