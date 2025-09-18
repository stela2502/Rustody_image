# Variables
VERSION := 1.5
IMAGE_NAME := Rustody_v$(VERSION).sif
SANDBOX_DIR := Rustody
DEFINITION_FILE := Rustody.def

# Assuming COSMOS shared folders are mounted in $(HOME)/sens05_shared on the development computer
# Paths on the development computer where the image will be deployed
DEPLOY_DIR := $(HOME)/sens05_shared/common/software/$(SANDBOX_DIR)/$(VERSION)
MODULE_FILE := $(HOME)/sens05_shared/common/modules/$(SANDBOX_DIR)/$(VERSION).lua

# Path on COSMOS where the image will be stored
SERVER_DIR := /scale/gr01/shared/common/software/$(SANDBOX_DIR)/$(VERSION)

# ==== configuration ====
BIN_DIR := ./        # where the executables will end up
TARGET  := x86_64-unknown-linux-musl
REPOS   := \
    https://github.com/stela2502/Rustody.git \
    https://github.com/stela2502/rust-geo-prep.git \
    https://github.com/stela2502/multi_subset_bam.git \
    https://github.com/stela2502/bam_aligner.git \
    https://github.com/stela2502/RustySparseMMX.git \
    https://github.com/stela2502/bam_tide.git \
    https://github.com/stela2502/bam_re_tagger.git \
    https://github.com/stela2502/regionomics.git \
    https://github.com/stela2502/image_cli.git

NAMES   := $(notdir $(basename $(REPOS)))

# Phony targets are not actual files, but represent actions
.PHONY: all restart build deploy clean

# Default target - runs all the steps
all: clean restart build deploy

# Restart the sandbox - creates or updates the sandbox
restart:
	@echo "Restarting sandbox..."
	@if [ -d $(SANDBOX_DIR) ]; then \
		echo "Updating existing sandbox..."; \
	else \
		echo "Creating new sandbox..."; \
	fi
	unset SINGULARITY_BIND
	sudo apptainer build --sandbox $(SANDBOX_DIR) $(DEFINITION_FILE)

# Build the .sif image from the definition file or sandbox
build:
	@echo "Building $(IMAGE_NAME) from $(SANDBOX_DIR)..."
	sudo apptainer build $(IMAGE_NAME) $(SANDBOX_DIR)

# Deploy the image by copying it to the deployment directory
deploy:
	@echo "Deploying $(IMAGE_NAME) to $(DEPLOY_DIR)..."
	@mkdir -p $(DEPLOY_DIR)
	rsync -avh --no-perms --no-owner --no-group --progress $(IMAGE_NAME) $(DEPLOY_DIR)
	@mkdir -p $(dir $(MODULE_FILE))
	@if [ ! -f $(MODULE_FILE) ]; then \
           $(CURDIR)/generate_module.sh $(SERVER_DIR) $(VERSION) $(SANDBOX_DIR) > $(MODULE_FILE);\
	   mkdir -p $(DEPLOY_DIR)/bin; \
	   cp $(CURDIR)/bin/* $(DEPLOY_DIR)/bin/; \
	   sed -i 's/^VERSION=.*/VERSION=${VERSION}/' $(DEPLOY_DIR)/bin/Rustody ; \
	   chmod +x $(DEPLOY_DIR)/bin/*; \
	fi

# Clean up the sandbox and image
clean:
	@echo "Cleaning up..."
	sudo rm -rf $(SANDBOX_DIR)
	sudo rm -f $(IMAGE_NAME)
static_binaries:
	@mkdir -p $(BIN_DIR)
	@for repo in $(REPOS); do \
	    echo "===> Installing $$repo to $(TARGET)"; \
	    cargo install --git $$repo --target $(TARGET) --root $(BIN_DIR); \
	done
	
