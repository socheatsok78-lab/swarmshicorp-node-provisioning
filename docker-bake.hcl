variable "ALPINE_VERSION" {
    default = "latest"
}

target "docker-metadata-action" {}
target "github-metadata-action" {}

target "default" {
    inherits = [
        "swarmshicorp-node-provisioning",
    ]
    platforms = [
        "linux/amd64",
        "linux/arm64"
    ]
}

target "makefile" {
    inherits = [
        "swarmshicorp-node-provisioning",
    ]
    tags = [
        "swarmshicorp-node-provisioning:local"
    ]
}

target "swarmshicorp-node-provisioning" {
    context = "."
    dockerfile = "Dockerfile"
    inherits = [
        "docker-metadata-action",
        "github-metadata-action",
    ]
    args = {
        ALPINE_VERSION = "${ALPINE_VERSION}"
    }
}
