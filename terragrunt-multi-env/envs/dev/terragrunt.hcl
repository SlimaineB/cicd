include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/docker-app"
}

inputs = {
  network_name    = "net-dev"
  container_name  = "nginx-dev"
  external_port   = 808v # 8080 pour dev, 8081 staging, etc.
}
