terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.19.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.34.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
  }

  backend "gcs" {
    bucket      = "filrouge-main-gcs"
    prefix      = "terraform/state"
   #  credentials = "./../filrouge-main-sa.json"
  }
}


provider "google" {
  project     = local.project_id # au lieu de local.env_config["project_id"]
  region      = local.region_default
  credentials = file("./../filrouge-${local.current_env}-sa.json")
}


# Retrieve default client configuration
data "google_client_config" "default" {}


# Provider configuration for Kubernetes
provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}


# Provider configuration for Helm
provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}


# Module configuration for GKE
module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  version                    = "34.0.0"
  project_id                 = local.project_id
  region                     = local.region_default
  name                       = local.name
  network                    = "default"
  subnetwork                 = "default"
  ip_range_pods              = ""
  ip_range_services          = ""
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = true
  service_account            = local.service_account

  deletion_protection        = false

  # En ne spécifiant pas de bloc "node_pools", le module créera automatiquement un pool par défaut.
  remove_default_node_pool = false
}

# Module configuration for Helm
resource "kubernetes_namespace" "backend" {
  metadata {
    name = "backend-ns"
  }
}


resource "kubernetes_namespace" "frontend" {
  metadata {
    name = "frontend-ns"
  }
}


resource "null_resource" "helm_registry_login" {
  provisioner "local-exec" {
    command = "helm registry login -u oauth2accesstoken -p \"$(gcloud auth print-access-token)\" ${local.region_default}-docker.pkg.dev"
  }
}


resource "helm_release" "chart" {
  name       = local.release_name
  repository = local.repository
  chart      = local.chart
  version    = local.chart_version

  wait    = true
  timeout = 1000
}