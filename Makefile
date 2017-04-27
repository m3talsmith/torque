GO           := `which go`
GOOS         := linux
GOARCH       := amd64
APP_NAME     := torque
TARGET_BUILD := "$(APP_NAME)-$(GOOS)-$(GOARCH)"

CURRENT_DATE := $(shell date +'%Y%m%d-%s')

ROOT_PATH    := /deploy/$(APP_NAME)
CURRENT_PATH := $(ROOT_PATH)/current
NEW_PATH     := $(ROOT_PATH)/versions/$(CURRENT_DATE)

DEPLOY_KEY := "$(HOME)/.ssh/theverse_rsa"
DEPLOY_URL := "root@torque.rebelhold.com"
ROOT_URL   := "root@torque.rebelhold.com"

all: cross-compile deploy

.PHONY: cross-compile deploy create-deploy-structure scp-binary stop-server symlink-deploy start-server clean;

cross-compile:
	@echo "Cross compiling..."
	$(GO) generate
	GOOS=$(GOOS) GOARCH=$(GOARCH) $(GO) build -o ./builds/$(TARGET_BUILD)

deploy: create-deploy-structure scp-binary stop-server symlink-deploy start-server clean

create-deploy-structure:
	@echo "Deploying: building version path $(NEW_PATH)"
	@ssh -i $(DEPLOY_KEY) $(DEPLOY_URL) "mkdir -p $(NEW_PATH)"

scp-binary:
	@echo "Deploying: copying binary"
	@scp -i $(DEPLOY_KEY) ./builds/$(TARGET_BUILD) $(DEPLOY_URL):$(NEW_PATH)
	@ssh -i $(DEPLOY_KEY) $(DEPLOY_URL) "mv $(NEW_PATH)/$(TARGET_BUILD) $(NEW_PATH)/$(APP_NAME)"

stop-server:
	@echo "Deploying: shutting down old version"
	@ssh -i $(DEPLOY_KEY) $(ROOT_URL) "/etc/init.d/$(APP_NAME) stop"

symlink-deploy:
	@echo "Deploying: symlinking $(CURRENT_DATE)"
	@ssh -i $(DEPLOY_KEY) $(DEPLOY_URL) "rm -rf $(CURRENT_PATH) && ln -s $(NEW_PATH) $(CURRENT_PATH)"

start-server:
	@echo "Deploying: starting new version"
	# @ssh -i $(DEPLOY_KEY) $(ROOT_URL) "service $(APP_NAME) start"
	@ssh -i $(DEPLOY_KEY) $(ROOT_URL) "/etc/init.d/$(APP_NAME) start"

clean:
	@echo "Cleaning up cross-compiled bin..."
	@rm -rf builds