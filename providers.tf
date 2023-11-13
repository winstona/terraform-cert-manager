terraform {
  required_providers {
    kubectl = {
      # source  = "gavinbunney/kubectl"
      source  = "alekc/kubectl"
      version = ">= 1.7.0"
    }
  }
}