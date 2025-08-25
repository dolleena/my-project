REGISTRY ?= localhost:5001
APP ?= edgewatch-api
NAMESPACE ?= edgewatch
KIND_CLUSTER ?= edgewatch

.PHONY: init infra-up infra-down app-build app-push k8s-apply k8s-destroy jenkins-up jenkins-down test yocto-build device-run fmt

fmt:
	black app || true

init:
	kind create cluster --name $(KIND_CLUSTER) || true
	docker run -d -p 5001:5000 --restart always --name registry registry:2 || true
	kubectl create ns $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -

infra-up:
	cd infra/terraform && terraform init && terraform apply -auto-approve -var="registry=$(REGISTRY)" -var="image_tag=$$(git rev-parse --short HEAD)"

infra-down:
	cd infra/terraform && terraform destroy -auto-approve

app-build:
	docker build -t $(REGISTRY)/$(APP):$$(git rev-parse --short HEAD) app

app-push:
	docker push $(REGISTRY)/$(APP):$$(git rev-parse --short HEAD)

k8s-apply: infra-up

k8s-destroy: infra-down

jenkins-up:
	docker compose -f ci/jenkins-compose.yml up -d

jenkins-down:
	docker compose -f ci/jenkins-compose.yml down -v

test:
	docker run --rm -v $$PWD/app:/src -w /src python:3.12 bash -lc "pip install -r requirements.txt && pytest -q"

yocto-build:
	@echo "Yocto build: see yocto/build.sh (requires poky submodule)."

device-run:
	@echo "QEMU run: see yocto/run-qemu.sh"
