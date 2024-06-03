# Define the SSH username as a variable
SSH_USERNAME ?= 

.PHONY: all init plan apply destroy help

# Default target
all: init plan apply

# Initialize Terraform workspace and run terraform init
init:
	@if [ -z "$(SSH_USERNAME)" ]; then \
		echo "Error: SSH_USERNAME is not set. Please provide SSH_USERNAME=<ssh-username>."; \
		exit 1; \
	fi
	@if terraform workspace list | grep -q "$(SSH_USERNAME)"; then \
		read -p "Workspace $(SSH_USERNAME) already exists. Do you want to override it? (yes/no) " CONFIRM; \
		if [ "$$CONFIRM" != "yes" ]; then \
			echo "Initialization cancelled."; \
			exit 1; \
		fi; \
	fi
	@echo "Creating or selecting Terraform workspace: $(SSH_USERNAME)"
	@terraform workspace new $(SSH_USERNAME) || terraform workspace select $(SSH_USERNAME)
	@terraform init

# Run terraform plan with the provided SSH username
plan:
	@if [ -z "$(SSH_USERNAME)" ]; then \
		echo "Error: SSH_USERNAME is not set. Please provide SSH_USERNAME=<ssh-username>."; \
		exit 1; \
	fi
	@echo "Running terraform plan with name=$(SSH_USERNAME)"
	@terraform plan -var "name=$(SSH_USERNAME)"

# Run terraform apply with the provided SSH username
apply:
	@if [ -z "$(SSH_USERNAME)" ]; then \
		echo "Error: SSH_USERNAME is not set. Please provide SSH_USERNAME=<ssh-username>."; \
		exit 1; \
	fi
	@read -p "Are you sure you want to apply changes? [yes/no]: " answer; \
	if [ $$answer != "yes" ]; then \
		echo "Aborting apply."; \
		exit 1; \
	fi; \
	echo "Running terraform apply with name=$(SSH_USERNAME)"; \
	terraform apply -var "name=$(SSH_USERNAME)"

# Destroy Terraform-managed resources
destroy:
	@if [ -z "$(SSH_USERNAME)" ]; then \
		echo "Error: SSH_USERNAME is not set. Please provide SSH_USERNAME=<ssh-username>."; \
		exit 1; \
	fi
	@echo "Destroying Terraform-managed resources for workspace: $(SSH_USERNAME)"
	@terraform destroy -var "name=$(SSH_USERNAME)"

# Display help message
help:
	@echo "Usage:"
	@echo "  make [target] SSH_USERNAME=<ssh-username>"
	@echo ""
	@echo "Targets:"
	@echo "  all      - Runs init, plan, and apply in sequence"
	@echo "  init     - Creates or selects the Terraform workspace and initializes Terraform"
	@echo "  plan     - Runs terraform plan with the provided SSH username"
	@echo "  apply    - Runs terraform apply with the provided SSH username"
	@echo "  destroy  - Destroys Terraform-managed resources with the provided SSH username"
	@echo "  help     - Displays this help message"
