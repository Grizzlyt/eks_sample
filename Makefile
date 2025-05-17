APP_NAME=echo-server
IMAGE=your-registry/$(APP_NAME):latest
CHART_DIR=flux/echo_app/release/1.0.0

.PHONY: all build push test lint helm-lint deploy scan validate

all: lint test build push deploy

build:
	docker build -t $(IMAGE) .

push:
	docker push $(IMAGE)

lint:
	docker run --rm -i hadolint/hadolint < Dockerfile
	yamllint .

helm-lint:
	helm lint $(CHART_DIR)

test:
	echo "🧪 Replace this with actual test command"

scan:
	docker scan --accept-license --dependency-tree $(IMAGE)

validate:
	kubeval --strict $(CHART_DIR)/templates/*.yaml

deploy:
	cd $(CHART_DIR) && kustomize edit set image $(APP_NAME)=$(IMAGE)
	git add $(CHART_DIR)/kustomization.yaml
	git commit -m "Update image to $(IMAGE)"
	git push
