REGISTRY ?= localhost:5001
APP ?= edgewatch-api
NAMESPACE ?= edgewatch
KIND_CLUSTER ?= edgewatch

.PHONY: init infra-up infra-down app-build app-push k8s-apply k8s-destroy jenkins-up jenkins-down test yocto-build device-run fmt

fmt:
\tblack app || true

init:
\tkind create cluster --name $(KIND_CLUSTER) || true
\tdocker run -d -p 5001:5000 --restart always --name registry registry:2 || true
\tkubectl create ns $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -

infra-up:
\tcd infra/terraform && terraform init && terraform apply -auto-approve -var="registry=$(REGISTRY)" -var="image_tag=$$(git rev-parse --short HEAD)"

infra-down:
\tcd infra/terraform && terraform destroy -auto-approve

app-build:
\tdocker build -t $(REGISTRY)/$(APP):$$(git rev-parse --short HEAD) app

app-push:
\tdocker push $(REGISTRY)/$(APP):$$(git rev-parse --short HEAD)

k8s-apply: infra-up

k8s-destroy: infra-down

jenkins-up:
\tdocker compose -f ci/jenkins-compose.yml up -d

jenkins-down:
\tdocker compose -f ci/jenkins-compose.yml down -v

test:
\tdocker run --rm -v $$PWD/app:/src -w /src python:3.12 bash -lc "pip install -r requirements.txt && pytest -q"

yocto-build:
\t@echo "Yocto build: see yocto/build.sh (requires poky submodule)."

device-run:
\t@echo "QEMU run: see yocto/run-qemu.sh"
