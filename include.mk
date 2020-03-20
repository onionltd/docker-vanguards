.PHONY: all
all:

.PHONY: build
build:
	docker build $(DOCKER_OPTS) -t "$(DOCKER_IMAGE):$(DOCKER_IMAGE_TAG)" .
