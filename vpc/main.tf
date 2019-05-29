provider "aws" {
  region = "eu-west-1"
}
locals {
  common_tags = "${map(
    "project", "eks-git280519"
  )}"
}
resource "aws_vpc" "eks" {
  cidr_block       = "${var.cidr_block}"
//  instance_tenancy = "${var.instance_tenancy}"
  enable_dns_hostnames = "${var.enable_dns_hostname}"
  enable_dns_support = "${var.enable_dns_support}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "vpc-eks"
    )
  )}"
}
resource "aws_internet_gateway" "eks-igw" {
  vpc_id = "${aws_vpc.eks.id}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "igw-vpc-eks"
    )
  )}"
}
resource "aws_subnet" "public" {
  count = "${length(var.public_cidr_block)}"

  vpc_id            = "${aws_vpc.eks.id}"
  cidr_block        = "${var.public_cidr_block[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
  

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "subnet-public-eks-${count.index + 1}"
    )
  )}"
}
resource "aws_subnet" "private" {
  count = "${length(var.private_cidr_block)}"

  vpc_id            = "${aws_vpc.eks.id}"
  cidr_block        = "${var.private_cidr_block[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "subnet-private-eks-${count.index + 1}"
    )
  )}"
}
resource "aws_route_table" "public" {
  count  = "${length(var.public_cidr_block)}"
  vpc_id = "${aws_vpc.eks.id}"

  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eks-igw.id}"
  }

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "rt-public-${count.index + 1}"
    )
  )}"
}
resource "aws_route_table_association" "public" {
  count          = "${length(var.public_cidr_block)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}
resource "aws_route_table" "private" {
  count  = "${length(var.private_cidr_block)}"
  vpc_id = "${aws_vpc.eks.id}"

  route = {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.eks-nat.id}"
  }

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "rt-private-${count.index + 1}"
    )
  )}"
}
resource "aws_route_table_association" "private" {
  count          = "${length(var.private_cidr_block)}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
resource "aws_eip" "eip" {
  vpc = true

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "eip"
    )
  )}"
}
resource "aws_nat_gateway" "eks-nat" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "nat gateway"
    )
  )}"

  depends_on = ["aws_internet_gateway.eks-igw"]
}
resource "aws_security_group" "eks_ssh_sg" {
  name        = "${var.security_group_name}-ssh"
  description = "sg-${var.security_group_description}"
  vpc_id      = "${aws_vpc.eks.id}"
}
resource "aws_security_group_rule" "ingress_rule_ssh" {
  security_group_id = "${aws_security_group.eks_ssh_sg.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${element(var.inbound_rules_cluster[count.index], 0)}"]
  type              = "ingress"
}
resource "aws_security_group_rule" "egress_rule" {
  count             = "${length(var.outbound_rules)}"
  type              = "egress"
  cidr_blocks       = ["${element(var.outbound_rules[count.index], 0)}"]
  from_port         = "${element(var.outbound_rules[count.index], 1)}"
  to_port           = "${element(var.outbound_rules[count.index], 2)}"
  protocol          = "${element(var.outbound_rules[count.index], 3)}"
  security_group_id = "${aws_security_group.eks_ssh_sg.id}"
}
resource "aws_security_group" "eks_cluster_sg" {
  name        = "cluster-${var.security_group_name}"
  description = "sg-${var.security_group_description}"
  vpc_id      = "${aws_vpc.eks.id}"
}
resource "aws_security_group_rule" "ingress_rule_cluster" {
  count             = "${length(var.inbound_rules_cluster)}"
  type              = "ingress"
  cidr_blocks       = ["${element(var.inbound_rules_cluster[count.index], 0)}"]
  from_port         = "${element(var.inbound_rules_cluster[count.index], 1)}"
  to_port           = "${element(var.inbound_rules_cluster[count.index], 2)}"
  protocol          = "${element(var.inbound_rules_cluster[count.index], 3)}"
  security_group_id = "${aws_security_group.eks_cluster_sg.id}"
}
resource "aws_security_group" "eks_nodes_sg" {
  name        = "nodes-${var.security_group_name}"
  description = "sg-${var.security_group_description}"
  vpc_id      = "${aws_vpc.eks.id}"
}
resource "aws_security_group_rule" "ingress_rule_nodes" {
  count             = "${length(var.inbound_rules_nodes)}"
  type              = "ingress"
  cidr_blocks       = ["${element(var.inbound_rules_nodes[count.index], 0)}"]
  from_port         = "${element(var.inbound_rules_nodes[count.index], 1)}"
  to_port           = "${element(var.inbound_rules_nodes[count.index], 2)}"
  protocol          = "${element(var.inbound_rules_nodes[count.index], 3)}"
  security_group_id = "${aws_security_group.eks_nodes_sg.id}"
}
resource "aws_security_group_rule" "egress_rule_cluster" {
  count             = "${length(var.outbound_rules)}"
  type              = "egress"
  cidr_blocks       = ["${element(var.outbound_rules[count.index], 0)}"]
  from_port         = "${element(var.outbound_rules[count.index], 1)}"
  to_port           = "${element(var.outbound_rules[count.index], 2)}"
  protocol          = "${element(var.outbound_rules[count.index], 3)}"
  security_group_id = "${aws_security_group.eks_cluster_sg.id}"
}
resource "aws_security_group_rule" "egress_rule_nodes" {
  count             = "${length(var.outbound_rules)}"
  type              = "egress"
  cidr_blocks       = ["${element(var.outbound_rules[count.index], 0)}"]
  from_port         = "${element(var.outbound_rules[count.index], 1)}"
  to_port           = "${element(var.outbound_rules[count.index], 2)}"
  protocol          = "${element(var.outbound_rules[count.index], 3)}"
  security_group_id = "${aws_security_group.eks_nodes_sg.id}"
}