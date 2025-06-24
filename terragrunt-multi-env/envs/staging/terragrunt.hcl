include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/docker-app"
}

inputs = {
  network_name    = "net-staging"
  container_name  = "nginx-staging"
  external_port   = 808g # 8080 pour dev, 8081 staging, etc.
}
