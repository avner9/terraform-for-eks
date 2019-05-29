provider "aws" {
  region = "eu-west-1"
}
locals {
  common_tags = "${map(
    "Project", "eks-git280519"
  )}"
}
resource "aws_vpc" "eks" {
  cidr_block       = "${var.cidr}"
  instance_tenancy = "${var.instance_tenancy}"
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
  count = "${length(var.public_subnets)}"

  vpc_id            = "${aws_vpc.eks.id}"
  cidr_block        = "${var.public_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
  

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "subnet-public-vpc-eks-${count.index + 1}"
    )
  )}"
}
resource "aws_subnet" "private" {
  count = "${length(var.private_subnets)}"

  vpc_id            = "${aws_vpc.eks.id}"
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "subnet-private-vpc-eks-${count.index + 1}"
    )
  )}"
}
resource "aws_route_table" "public" {
  count  = "${length(var.public_subnets)}"
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
  count          = "${length(var.public_subnets)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}
resource "aws_route_table" "private" {
  count  = "${length(var.public_subnets)}"
  vpc_id = "${aws_vpc.eks.id}"

  route = {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.eks.id}"
  }

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "rt-private-${count.index + 1}"
    )
  )}"
}
resource "aws_route_table_association" "private" {
  count          = "${length(var.public_subnets)}"

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

  depends_on = ["aws_internet_gateway.eks-igw"]
}