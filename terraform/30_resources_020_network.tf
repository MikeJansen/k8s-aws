resource "aws_vpc" "vpc" {
  cidr_block = local.vpc_cidr
  tags = {
    Name = "k8s-network"
    Project = var.project_name
  }
}

resource "aws_subnet" "cp_subnets" {
  count = length(var.aws_zones)
  vpc_id = aws_vpc.vpc.id
  cidr_block = local.cp_subnet_cidrs[count.index]
  availability_zone = var.aws_zones[count.index]
  tags = {
    Name = "k8s-cp-subnet-${count.index}"
    Project = var.project_name
  }
}

resource "aws_subnet" "worker_subnets" {
  count = length(var.aws_zones)
  vpc_id = aws_vpc.vpc.id
  cidr_block = local.worker_subnet_cidrs[count.index]
  availability_zone = var.aws_zones[count.index]
  tags = {
    Name = "k8s-worker-subnet-${count.index}"
    Project = var.project_name
  }
}
