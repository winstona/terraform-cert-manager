locals {
    namespace = "cert-manager"
    letsencrypt_urls = {
      "prod": "https://acme-v02.api.letsencrypt.org/directory",
      "staging": "https://acme-staging-v02.api.letsencrypt.org/directory"
    }
}

module "helm-release" {
  source = "../terraform-helm-release"

  count = var.install_helm_chart ? 1 : 0

  name = var.name
  create_namespace = true
  namespace = local.namespace
  release_name = "cert-manager"
  helm_repo_url = "https://charts.jetstack.io"
  values = <<-EOF
    installCRDs: true
    cainjector:
      enabled: true
    EOF
  

}


# TODO: wait for helm-release to be deployed fully

resource "kubectl_manifest" "cluster_issuer" {
  yaml_body = <<-YAML
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: ${var.name}
      namespace: ${local.namespace}
    spec:
      acme:
        server: ${local.letsencrypt_urls[var.letsencrypt_environment]}
        privateKeySecretRef:
            name: cluster-issuer-account-key
        solvers:
            - dns01:
                digitalocean:
                    tokenSecretRef:
                        name: ${var.secret_name}
                        key: access-token
  YAML

  depends_on = [ module.helm-release ]
}


resource "kubectl_manifest" "cluster_issuer_self_signed" {
  yaml_body = <<-YAML
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: ${var.name}-selfsigned
      namespace: ${local.namespace}
    spec:
      selfSigned: {}
  YAML

  depends_on = [ module.helm-release ]
}