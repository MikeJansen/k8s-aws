resource "aws_security_group" "cp" {
  name = "k8s-cp"
  description = "K8S Control Plane Security Group"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "k8s-cp"
    Project = var.project_name
  }
}

resource "aws_security_group" "worker" {
  name = "k8s-work"
  description = "K8S Worker Node Security Group"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "k8s-worker"
    Project = var.project_name
  }
}

resource "aws_security_group_rule" "intra_cp_ingress_api" {
  type = "ingress"
  security_group_id = aws_security_group.cp.id
  from_port = var.k8s_api_port
  to_port = var.k8s_api_port
  protocol = "tcp"
  description = "Intra CP Ingress - API"
  source_security_group_id = aws_security_group.cp.id
}

resource "aws_security_group_rule" "intra_cp_ingress_etcd" {
  type = "ingress"
  security_group_id = aws_security_group.cp.id
  from_port = 2379
  to_port = 2380
  protocol = "tcp"
  description = "Intra CP Ingress - etcd"
  source_security_group_id = aws_security_group.cp.id
}

resource "aws_security_group_rule" "intra_cp_ingress_kubelet_api" {
  type = "ingress"
  security_group_id = aws_security_group.cp.id
  from_port = 10250
  to_port = 10259
  protocol = "tcp"
  description = "Intra CP Ingress - Kubelet API"
  source_security_group_id = aws_security_group.cp.id
}

resource "aws_security_group_rule" "intra_cp_ingress_scheduler" {
  type = "ingress"
  security_group_id = aws_security_group.cp.id
  from_port = 10259
  to_port = 10259
  protocol = "tcp"
  description = "Intra CP Ingress - Scheduler"
  source_security_group_id = aws_security_group.cp.id
}

resource "aws_security_group_rule" "intra_cp_ingress_controller_manager" {
  type = "ingress"
  security_group_id = aws_security_group.cp.id
  from_port = 10257
  to_port = 10257
  protocol = "tcp"
  description = "Intra CP Ingress - Controller Manager"
  source_security_group_id = aws_security_group.cp.id
}

# could be restricted to 10250/kubet and 30000-32767/NodePort?
resource "aws_security_group_rule" "cp_to_worker_ingress_all" {
  type = "ingress"
  security_group_id = aws_security_group.worker.id
  from_port = -1
  to_port = -1
  protocol = "-1"
  description = "CP to Worker Ingress"
  source_security_group_id = aws_security_group.cp.id
}

# could be restricted same as intra-cp
resource "aws_security_group_rule" "worker_to_cp_ingress_all" {
  type = "ingress"
  security_group_id = aws_security_group.cp.id
  from_port = -1
  to_port = -1
  protocol = "-1"
  description = "Worker to CP Ingress"
  source_security_group_id = aws_security_group.worker.id
}

# could be restricted same as cp to worker ?
resource "aws_security_group_rule" "intra_worker_ingress_all" {
  type = "ingress"
  security_group_id = aws_security_group.worker.id
  from_port = -1
  to_port = -1
  protocol = "-1"
  description = "Intra Worker Ingress"
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "trusted_to_cp_ingress_ssh" {
  count = length(var.trusted_cidrs)
  type = "ingress"
  security_group_id = aws_security_group.cp.id
  from_port = 22
  to_port = 22
  protocol = "tcp"
  description = "Trusted (${var.trusted_cidrs[count.index]["description"]}) to CP Ingress - SSH"
  cidr_blocks = [
    var.trusted_cidrs[count.index]["cidr"]
  ]
}

resource "aws_security_group_rule" "trusted_to_cp_ingress_api" {
  count = length(var.trusted_cidrs)
  type = "ingress"
  security_group_id = aws_security_group.cp.id
  from_port = var.k8s_api_port
  to_port = var.k8s_api_port
  protocol = "tcp"
  description = "Trusted (${var.trusted_cidrs[count.index]["description"]}) to CP Ingress - API"
  cidr_blocks = [
    var.trusted_cidrs[count.index]["cidr"]
  ]
}

resource "aws_security_group_rule" "trusted_to_cp_ingress_service" {
  count = length(var.trusted_cidrs)
  type = "ingress"
  security_group_id = aws_security_group.cp.id
  from_port = 30000
  to_port = 32767
  protocol = "tcp"
  description = "Trusted (${var.trusted_cidrs[count.index]["description"]}) to CP Ingress - Service"
  cidr_blocks = [
    var.trusted_cidrs[count.index]["cidr"]
  ]
}

resource "aws_security_group_rule" "trusted_to_worker_ingress_ssh" {
  count = length(var.trusted_cidrs)
  type = "ingress"
  security_group_id = aws_security_group.worker.id
  from_port = 22
  to_port = 22
  protocol = "tcp"
  description = "Trusted (${var.trusted_cidrs[count.index]["description"]}) to Worker Ingress - SSH"
  cidr_blocks = [
    var.trusted_cidrs[count.index]["cidr"]
  ]
}

