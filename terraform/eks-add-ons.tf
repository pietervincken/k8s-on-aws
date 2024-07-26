resource "aws_eks_addon" "ebs_csi" {
  cluster_name = module.eks.cluster_name
  addon_name   = "aws-ebs-csi-driver"
}

resource "aws_eks_addon" "snapshot_controller" {
  cluster_name = module.eks.cluster_name
  addon_name   = "snapshot-controller"
}

resource "aws_eks_addon" "eks_pod_identity_agent" {
  cluster_name = module.eks.cluster_name
  addon_name   = "eks-pod-identity-agent"
}