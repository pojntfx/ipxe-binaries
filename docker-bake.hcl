#https://docs.docker.com/build/customize/bake/file-definition/
variable "TAG" {}
variable "REPO" {}
variable "CREATED" {}
variable "DESCRIPTION" {}
variable "URL" {}
variable "SHA" {}
variable "SHA_SHORT" {}
variable "AUTHOR" {}

group "default" {
  targets = ["image"]
}

target "image" {
  dockerfile = "./Dockerfile"

  tags = [
    "ghcr.io/${REPO}:${TAG}",
    "ghcr.io/${REPO}:${SHA_SHORT}"
  ]

  args = {
    TAG = "${TAG}"
  }

  labels = {
    "org.opencontainers.artifact.created" = "${CREATED}"
    "org.opencontainers.artifact.description" = "${DESCRIPTION}"
    "org.opencontainers.image.created" = "${CREATED}"
    "org.opencontainers.image.authors" = "${AUTHOR}"
    "org.opencontainers.image.url" = "${URL}"
    "org.opencontainers.image.source" = "${URL}"
    "org.opencontainers.image.version" = "${SHA}"
    "org.opencontainers.image.revision" = "${SHA}"
    "org.opencontainers.image.title" = "${DESCRIPTION}"
    "org.opencontainers.image.description" = "${DESCRIPTION} built on alpine:${TAG}"
    "org.opencontainers.image.base.name" = "docker.io/alpine:${TAG}"
  }

  platforms = ["linux/arm64", "linux/armhf", "linux/arm/v7", "linux/ppc64le", "linux/s390x", "linux/386", "linux/amd64"]
  #platforms = ["linux/arm64", "linux/amd64"]
}