# Version variables
TERRAFORM_VERSION := $(shell cat .terraform-version)
TOFU_VERSION	  := $(shell cat .terraform-version)

# Select Terraform or OpenTofu engine
TF_ENGINE ?= terraform
ifeq ($(TF_ENGINE), terraform)
	TF_BINARY  := terraform 
	TF_VERSION := $(TERRAFORM_VERSION)
else ifeq ($(TF_ENGINE), opentofu)
	TF_BINARY  := tofu
	TF_VERSION := $(TOFU_VERSION)
endif

# Use local version with tenv (skip in CI)
ifeq ($(CI), )
	TFENV_COMMAND := tenv use $(TF_BINARY) $(TF_VERSION)
else
	TFENV_COMMAND := echo "skipping tenv use in CI"
endif

# Packages to install
BREW_PACKAGES		:= cosign tenv terraform-docs tflint checkov trivy pre-commit golang
CHOCOLATEY_PACKAGES  := cosign tenv terraform-docs tflint trivy golang
APT_PACKAGES		 := curl git unzip wget gnupg lsb-release software-properties-common python3-pip golang pre-commit
APK_PACKAGES		 := cosign

INSTALLER_PATH := $(shell { command -v apt || command -v brew || command -v choco ; } 2>/dev/null)
INSTALLER	  := $(shell { basename $(INSTALLER_PATH) ; } 2>/dev/null)
MODULE_DIRECTORY_NAME := $(shell { pwd | rev | cut -d"/" -f 1 | rev ; } 2>/dev/null)
TERRATEST_FILES := $(wildcard tests/*_test.go)

CHECKOV_OPTS :=
GO_TEST_OPTS  :=

# Main targets
.PHONY: all help chores test clean install install_brew install_choco install_apt \
	format test_format documentation test_documentation fix_tflint test_tflint \
	test_security test_checkov test_trivy terraform_test test_validation \
	precommit_install precommit_run $(TERRAFORM_EXAMPLES)

all: help

help:
	@echo "Available targets:"
	@echo "  install			 Install dependencies for your system"
	@echo "  format			  Format Terraform code"
	@echo "  test_format		 Check Terraform code formatting"
	@echo "  documentation	   Generate documentation"
	@echo "  test_documentation  Check documentation"
	@echo "  test_tflint		 Lint Terraform code"
	@echo "  test_security	   Run security checks (Checkov + Trivy)"
	@echo "  test_validation	 Validate Terraform syntax"
	@echo "  terraform_test	  Run Terraform tests"
	@echo "  clean			   Clean generated files"
	@echo "  precommit_install   Install pre-commit hooks"
	@echo "  precommit_run	   Run all pre-commit hooks"

chores: documentation format

test: test_documentation test_tflint test_security test_validation test_format terraform_test

# Installation
install: install_$(INSTALLER)

install_brew:
	@echo "==> Installing dependencies with Homebrew"
	brew tap tofuutils/tap
	brew install $(BREW_PACKAGES)

install_choco:
	@echo "==> Installing dependencies with Chocolatey"
	choco install $(CHOCOLATEY_PACKAGES)

install_apt:
	@echo "==> Installing dependencies with apt"
	sudo apt-get update
	sudo apt-get install -y $(APT_PACKAGES)
	@echo "==> Upgrading pip and installing checkov"
	pip install --upgrade pip
	pip install checkov detect-secrets trufflehog
	@echo "==> Installing Terraform from HashiCorp repo"
	curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
	sudo apt-get update && sudo apt-get install -y terraform
	@echo "==> Installing tflint"
	curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
	@echo "==> Installing terraform-docs"
	curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.20.0/terraform-docs-v0.20.0-Linux-amd64.tar.gz
	tar -xzf terraform-docs.tar.gz
	chmod +x terraform-docs
	sudo mv terraform-docs /usr/local/bin/
	rm terraform-docs.tar.gz
	@echo "==> Installing cosign"
	curl -sSLO https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
	chmod +x cosign-linux-amd64
	sudo mv cosign-linux-amd64 /usr/local/bin/cosign
	@echo "==> Installing trivy"
	curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin

# Terraform workspace setup
.terraform:
	@echo "==> Initializing Terraform workspace"
	$(TF_BINARY) -chdir=terraform init -backend=false

# Formatting

format:
	@echo "==> Formatting Terraform code"
	$(TF_BINARY) fmt -recursive terraform

test_format:
	@echo "==> Checking Terraform code formatting"
	$(TF_BINARY) fmt -check -recursive terraform

# Documentation

documentation:
	@echo "==> Generating documentation"
	terraform-docs -c .terraform-docs.yml .

test_documentation:
	@echo "==> Checking documentation"
	terraform-docs -c .terraform-docs.yml --output-check .

# Linting

fix_tflint:
	@echo "==> Auto-fixing with tflint"
	tflint --init
	tflint --fix

test_tflint:
	@echo "==> Running static analysis with tflint"
	tflint --init
	tflint

# Unit Test

terraform_test:
	@echo "==> Running Terraform tests"
	$(TF_BINARY) -chdir=terraform test 

# Security

test_security: test_checkov test_trivy test_secrets

test_checkov:
	@echo "==> Running security analysis with checkov"
	checkov --directory terraform $(CHECKOV_OPTS)

test_trivy:
	@echo "==> Running security analysis with trivy"
	trivy config terraform

# Validation

test_validation: .terraform
	@echo "==> Validating Terraform syntax"
	$(TF_BINARY) validate terraform

# Clean

clean:
	@echo "==> Cleaning generated files"
	rm -rf .terraform .terraform.lock.hcl

# Pre-commit

precommit_install:
	@echo "==> Installing pre-commit hooks"
	pre-commit install

precommit_run:
	@echo "==> Running all pre-commit hooks"
	pre-commit run -a

test_secrets_detect:
	@echo "==> Scanning for secrets with detect-secrets"
	detect-secrets scan --all-files terraform > .secrets.baseline
	detect-secrets audit .secrets.baseline

test_secrets: test_secrets_detect 