output "vpc_id" {
  value = "${aws_vpc.eks.id}"
}
output "vpc_cidr_block" {
  value = "${aws_vpc.eks.cidr_block}"
}
output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}
output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}
output "public_subnet_cidr_block" {
  value = ["${aws_subnet.public.*.cidr_block}"]
}
output "private_subnet_cidr_block" {
  value = ["${aws_subnet.private.*.cidr_block}"]
}
output "nat_eip" {
  value = ["${aws_eip.eip.public_ip}"]
}
output "ssh_security_group" {
  value = "${aws_security_group.eks_ssh_sg.id}"
}
output "nodes_security_group" {
  value = "${aws_security_group.eks_nodes_sg.id}"
}
output "cluster_security_group" {
  value = "${aws_security_group.eks_cluster_sg.id}"
}

