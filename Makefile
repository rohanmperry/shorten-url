TERRAFORM_DIR := terraform

.PHONY: init up down plan fmt lint test

AUTO_APPROVE := $(if $(TF_IN_AUTOMATION),-auto-approve,)

unexport AWS_PROFILE

ifndef TF_IN_AUTOMATION
export AWS_PROFILE := projects
$(info Running locally, using AWS credentials from profile)
else
$(info Running in CI, using ODIC AWS credentials)
endif

init:
	terraform -chdir=$(TERRAFORM_DIR) init

validate:
	terraform -chdir=$(TERRAFORM_DIR) validate

plan:
	terraform -chdir=$(TERRAFORM_DIR) plan

package:
	zip -j bin/create_short_url.zip src/create_short_url/handler.py src/shared/utils.py
	zip -j bin/redirect.zip src/redirect/handler.py src/shared/utils.py

apply:
	terraform -chdir=$(TERRAFORM_DIR) apply $(AUTO_APPROVE)

destroy:
	terraform -chdir=$(TERRAFORM_DIR) destroy $(AUTO_APPROVE)

fmt:
	terraform -chdir=$(TERRAFORM_DIR) fmt -recursive

test:
	pytest tests/ -v
