resource "aws_eks_cluster" "eks_cluster" {
    name = "project-bedrock-cluster"
    access_config {
      authentication_mode = "API"
    }
    version = "1.31"
    
    vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
      subnet_ids = var.private_subnets_id

    }
    
    compute_config {
    enabled       = true
    node_pools    = ["general-purpose"]
    node_role_arn = aws_iam_role.eks_node.arn
  }
    kubernetes_network_config {
      elastic_load_balancing {
        enabled = true
      }
      
    }
    role_arn = aws_iam_role.cluster_iam_role.arn
    depends_on = [ aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryPullOnly,aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodeMinimalPolicy, aws_iam_role_policy_attachment.cluster_AmazonEKSLoadBalancingPolicy ]
  tags = {
    Project = "Bedrock"
    Terraform   = "true"
  }

}

resource "aws_eks_node_group" "eks_node_group" {
    ami_type = "AL2_x86_64"
  scaling_config {
  
    desired_size = 3
    max_size = 4
    min_size = 1
    
  }
  subnet_ids = var.private_subnets_id
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_role_arn = aws_iam_role.eks_node.arn
  depends_on = [ aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodeMinimalPolicy ]

}

resource "aws_iam_role" "eks_node" {
  name = "project-bedrock-node-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodeMinimalPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role" "cluster_iam_role" {
    name = "project-bedrock-cluster-iam-role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
  
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_iam_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSLoadBalancingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.cluster_iam_role.name
}

