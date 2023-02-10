data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    value = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "cp" {
  count = var.num_cps
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = var.ec2_key_name
  security_groups = [ aws_security_group.cp.id ]
  subnet_id = aws_subnet.cp_subnets[count.index % length(aws_subnet.cp_subnets)]
  source_dest_check = false
  tags = {
    Name = "k8s-cp${count.index}"
    K8s-Role = "cp"
    Role = "k8s"
    Project = var.project_name
  }
  depends_on = [aws_internet_gateway.igw]  
}

resource "aws_eip" "cp" {
  count = var.num_cps
  instance = aws_instance.cp[count.index]
  depends_on = [aws_internet_gateway.igw]  
}
