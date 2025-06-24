terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "this" {
  name = var.network_name
}

resource "docker_container" "nginx" {
  name  = var.container_name
  image = "nginx:latest"
  networks_advanced {
    name = docker_network.this.name
  }
  ports {
    internal = 80
    external = var.external_port
  }
}
