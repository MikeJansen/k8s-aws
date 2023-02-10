resource "aws_vpc" "vpc" {
  cidr_block = local.vpc_cidr
  tags = {
    Name = "k8s-network"
    Project = var.project_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "k8s-network"
    Project = var.project_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "k8s-public-subnet"
    Project = var.project_name
  }
}

resource "aws_route" "internet" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
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
  depends_on = [aws_internet_gateway.igw]  
}

resource "aws_route_table_association" "cp" {
  count = length(var.aws_subnet.cp_subnets)
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.cp_subnets[count.index]
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
  depends_on = [aws_internet_gateway.igw]  
}

resource "aws_route_table_association" "worker" {
  count = length(var.aws_subnet.worker_subnets)
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.worker_subnets[count.index]
}

