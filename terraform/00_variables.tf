# ----------------------------------------------------------
# Variables in this section should set before initial deploy
# and not modified afterwards.  They are the basic network
# layout and changing them could cause replacement of 
# existing compute resources.
#
# bits = 2^bits addresses available in that CIDR, not 
# relative to suffix.
#
# Pod and Service CIDRs will be created within the VPC CIDR
# to allow direct routing.
# ----------------------------------------------------------

variable "ec2_key_name" {
  type = string
  default = ""
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "aws_zones" {
  type = list(any)
  default = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
}

# 
variable "vpc_cidr_prefix" {
  default = "10.42.0.0"
  type = string
}

variable "vpc_cidr_suffix" {
  default = 20
  type = number
}

variable "cp_cidr_bits" {
  default = 7
  type = number
}

variable "worker_cidr_bits" {
  default = 8
  type = number
}

variable "pod_cidr_bits" {
  default = 10
  type = number
}

variable "pod_node_cidr_bits" {
  default = 8
  type = number
}

variable "service_cidr_bits" {
  default = 7
  type = number
}

variable "k8s_api_port" {
  default = 443
  type = number
}

# ----------------------------------------------------------
# These variables can be modified after initial rollout
# to scale or tweak
# ----------------------------------------------------------

variable "project_name" {
  type = string
  default = "k8s-aws"
}

variable "num_cps" {
  type = number
  default = 3
}

variable "num_workers" {
  type = number
  default = 5
}

variable "instance_type" {
  type = string
  default = "m6a.large"
}

variable "trusted_cidrs" {
    default = [
      {
        cidr = "173.90.193.167/32"
        description = "Home"
      }
    ]
    type = list(map(string))

    description = "List of trusted CIDRs for SSH, etc"
}

# ----------------------------------------------------------
# ----------------------------------------------------------

locals {
  vpc_cidr = "${var.vpc_cidr_prefix}/${var.vpc_cidr_suffix}"
  cidr_bases = cidrsubnets(local.vpc_cidr, 
    32 - var.vpc_cidr_suffix - var.cp_cidr_bits, 
    32 - var.vpc_cidr_suffix - var.worker_cidr_bits, 
    32 - var.vpc_cidr_suffix - var.pod_cidr_bits, 
    32 - var.vpc_cidr_suffix - var.service_cidr_bits) 
  cp_cidr_base = local.cidr_bases[0]
  worker_cidr_base = local.cidr_bases[1]
  pod_cidr_base = local.cidr_bases[2]
  service_cidr_base = local.cidr_bases[3]
  cp_subnet_cidrs = [
    for idx in range(length(var.aws_zones)) :
      cidrsubnet(local.cp_cidr_base, 3, idx )
  ]
  worker_subnet_cidrs = [
    for idx in range(length(var.aws_zones)) :
      cidrsubnet(local.worker_cidr_base, 3, idx)
  ]
  service_ip     = cidrhost(local.service_cidr_base, 1)
  cluster_dns_ip = cidrhost(local.service_cidr_base, 10)
  pod_node_cidrs = [
    for idx in range(var.num_workers) :
      cidrsubnet(local.pod_cidr_base, 5, idx)
  ]
}
