# Deploy Flux using Helm and target infra node pool
resource "helm_release" "flux" {
  name       = "flux-system"
  namespace  = "flux-system"
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  version    = "2.11.1"
  create_namespace = true

  values = [
    <<EOF
    installCRDs: true
    nodeSelector:
      role: infra
    tolerations:
      - key: "dedicated"
        operator: "Equal"
        value: "infra"
        effect: "NoSchedule"
    EOF
  ]

  depends_on = [module.eks]
}

resource "kubernetes_manifest" "echo_git_repository" {
  manifest = {
    apiVersion = "source.toolkit.fluxcd.io/v1"
    kind       = "GitRepository"
    metadata = {
      name      = "echo-app"
      namespace = "flux-system"
    }
    spec = {
      interval = "1m"
      url      = "https://github.com/Grizzlyt/eks_sample"
      ref = {
        branch = "master"
      }
    }
  }
  depends_on = [helm_release.flux]
}

resource "kubernetes_manifest" "app_kustomization" {
  manifest = {
    apiVersion = "kustomize.toolkit.fluxcd.io/v1"
    kind       = "Kustomization"
    metadata = {
      name      = "apps-kustomize"
      namespace = "flux-system"
    }
    spec = {
      interval         = "5m"
      path             = "./flux"
      prune            = true
      timeout          = "2m"
      targetNamespace  = "default"
      sourceRef = {
        kind = "GitRepository"
        name = "app-repo"
      }
    }
  }
  depends_on = [kubernetes_manifest.echo_git_repository]
}