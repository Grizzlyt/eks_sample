module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.31"
  cluster_name    = "gitops-cluster"
  cluster_version = "1.31"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium","t3a.medium"]
  }

  eks_managed_node_groups = {
    infrastructure = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 4
      desired_size = 2

      labels = {
        role = "infra"
      }
      taints = {
          dedicated = {
            key    = "dedicated"
            value  = "infra"
            effect = "NO_SCHEDULE"
          }
      }
    }

    application = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 4
      desired_size = 2

      labels = {
        role = "app"
      }
      taints = {
          dedicated = {
            key    = "dedicated"
            value  = "app"
            effect = "NO_SCHEDULE"
          }
      }
    }
  }

  access_entries = {
    eks-admin-group = {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/${aws_iam_group.eks_admin.name}"
      policy_arns   = ["arn:aws:eks::aws:cluster-access-policy/AWSManaged_EKSClusterAdmin"]
      type          = "STANDARD"
      access_scope  = {
        type = "cluster"
      }
    }

    eks-readonly-group = {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/${aws_iam_group.eks_readonly.name}"
      policy_arns   = ["arn:aws:eks::aws:cluster-access-policy/AWSManaged_EKSReadOnly"]
      type          = "STANDARD"
      access_scope  = {
        type = "cluster"
      }
    }
  }
}