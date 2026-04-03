TERRAFORM_DIR := terraform

.PHONY: init up down plan fmt lint test

init:
	terraform -chdir=$(TERRAFORM_DIR) init

plan:
	terraform -chdir=$(TERRAFORM_DIR) plan

package:
	zip -j bin/create_short_url.zip src/create_short_url/handler.py src/shared/utils.py
	zip -j bin/redirect.zip src/redirect/handler.py src/shared/utils.py

up:
	terraform -chdir=$(TERRAFORM_DIR) init
	terraform -chdir=$(TERRAFORM_DIR) apply -auto-approve

down:
	terraform -chdir=$(TERRAFORM_DIR) destroy -auto-approve

fmt:
	terraform -chdir=$(TERRAFORM_DIR) fmt -recursive

lint:
	terraform -chdir=$(TERRAFORM_DIR) validate

test:
	pytest tests/ -v
