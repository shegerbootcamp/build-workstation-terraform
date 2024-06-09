# Define the SSH username as a variable
name ?= 

.PHONY: all init plan apply destroy help

# Default target
all: init plan apply

# Initialize Terraform workspace and run terraform init
init:
	@if [ -z "$(name)" ]; then \
		echo "Error: name is not set. Please provide name=<ssh-username>."; \
		exit 1; \
	fi
	@if terraform workspace list | grep -q "$(name)"; then \
		read -p "Workspace $(name) already exists. Do you want to override it? (yes/no) " CONFIRM; \
		if [ "$$CONFIRM" != "yes" ]; then \
			echo "Initialization cancelled."; \
			exit 1; \
		fi; \
	fi
	@echo "Creating or selecting Terraform workspace: $(name)"
	@terraform workspace new $(name) || terraform workspace select $(name)
	@terraform init

# Run terraform plan with the provided SSH username
plan:
	@if [ -z "$(name)" ]; then \
		echo "Error: name is not set. Please provide name=<ssh-username>."; \
		exit 1; \
	fi
	@echo "Running terraform plan with name=$(name)"
	@terraform plan -var "name=$(name)"

# Run terraform apply with the provided SSH username
apply:
	@if [ -z "$(name)" ]; then \
		echo "Error: name is not set. Please provide name=<ssh-username>."; \
		exit 1; \
	fi
	@read -p "Are you sure you want to apply changes? [yes/no]: " answer; \
	if [ $$answer != "yes" ]; then \
		echo "Aborting apply."; \
		exit 1; \
	fi; \
	echo "Running terraform apply with name=$(name)"; \
	terraform apply -var "name=$(name)"

# Destroy Terraform-managed resources
destroy:
	@if [ -z "$(name)" ]; then \
		echo "Error: name is not set. Please provide name=<ssh-username>."; \
		exit 1; \
	fi
	@echo "Destroying Terraform-managed resources for workspace: $(name)"
	@terraform destroy -var "name=$(name)"

# Display help message
help:
	@echo "Usage:"
	@echo "  make [target] name=<ssh-username>"
	@echo ""
	@echo "Targets:"
	@echo "  all      - Runs init, plan, and apply in sequence"
	@echo "  init     - Creates or selects the Terraform workspace and initializes Terraform"
	@echo "  plan     - Runs terraform plan with the provided SSH username"
	@echo "  apply    - Runs terraform apply with the provided SSH username"
	@echo "  destroy  - Destroys Terraform-managed resources with the provided SSH username"
	@echo "  help     - Displays this help message"
