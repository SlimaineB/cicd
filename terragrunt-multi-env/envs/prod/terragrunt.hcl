include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/docker-app"
}

inputs = {
  network_name    = "net-prod"
  container_name  = "nginx-prod"
  external_port   = 808d # 8080 pour dev, 8081 staging, etc.
}
