DOCKER_IMAGE=localhost/vanguards
DOCKER_IMAGE_TAG=latest
DOCKER_OPTS=--build-arg "STEM_RELEASE=1.8.0" --build-arg "VANGUARDS_RELEASE=v0.3.1"

include include.mk
