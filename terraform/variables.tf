locals {
  current_env = terraform.workspace
  env_config  = lookup(var.env_settings, local.current_env, var.env_settings["dev"])
}

variable "env_settings" {
  description = "Paramètres spécifiques à chaque environnement"
  default = {
    "dev" = {
      "project_id"         = "filrouge-dev"
      "region_default"     = "europe-west1"
      "name"               = "gke-cluster"
      "machine_type"       = "n1-standard-1"
      "min_count"          = 1
      "max_count"          = 3
      "disk_size_gb"       = 10
      "service_account"    = "filrouge-dev-sa@filrouge-dev.iam.gserviceaccount.com"
      "initial_node_count" = 2
      "release_name"       = "myproject"
      "chart"              = "myproject"
      "chart_version"      = "0.1.0"
      "repository"         = "oci://europe-west1-docker.pkg.dev/filrouge-452215/mygcr"
    },
    "prod" = {
      "project_id"         = "filrouge-prod"
      "region_default"     = "europe-west1"
      "name"               = "gke-cluster"
      "machine_type"       = "n1-standard-1"
      "min_count"          = 1
      "max_count"          = 3
      "disk_size_gb"       = 10
      "service_account"    = "filrouge-prod-sa@filrouge-prod.iam.gserviceaccount.com"
      "initial_node_count" = 2
      "release_name"       = "myproject"
      "chart"              = "myproject"
      "chart_version"      = "0.1.0"
      "repository"         = "oci://europe-west1-docker.pkg.dev/filrouge-452215/mygcr"
    }
  }
}

locals {
  project_id         = local.env_config["project_id"]
  region_default     = local.env_config["region_default"]
  name               = local.env_config["name"]
  machine_type       = local.env_config["machine_type"]
  min_count          = local.env_config["min_count"]
  max_count          = local.env_config["max_count"]
  disk_size_gb       = local.env_config["disk_size_gb"]
  service_account    = local.env_config["service_account"]
  initial_node_count = local.env_config["initial_node_count"]
  release_name       = local.env_config["release_name"]
  chart              = local.env_config["chart"]
  chart_version      = local.env_config["chart_version"]
  repository         = local.env_config["repository"]
}