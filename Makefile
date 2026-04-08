TERRAFORM_DIR := terraform

.PHONY: init up down plan fmt lint test

AUTO_APPROVE := $(if $(TF_IN_AUTOMATION),-auto-approve,)

validate:
	terraform -chdir=$(TERRAFORM_DIR) validate

plan:
	make validate
	terraform -chdir=$(TERRAFORM_DIR) plan

package:
	zip -j bin/create_short_url.zip src/create_short_url/handler.py src/shared/utils.py
	zip -j bin/redirect.zip src/redirect/handler.py src/shared/utils.py

apply:
	make validate
	terraform -chdir=$(TERRAFORM_DIR) apply $(AUTO_APPROVE)

destroy:
	make validate
	terraform -chdir=$(TERRAFORM_DIR) destroy $(AUTO_APPROVE)

fmt:
	terraform -chdir=$(TERRAFORM_DIR) fmt -recursive

test:
	make validate
	pytest tests/ -v
