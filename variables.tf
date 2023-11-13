variable "name" {
    default = "cert-manager"
}

variable "install_helm_chart" {
    default = true
}

variable "letsencrypt_environment" {
    default = "prod"
}

variable "secret_name" {
    default = "digitalocean-dns"
}