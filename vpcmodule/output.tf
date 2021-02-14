output "public_subnets" {
  value = "${aws_subnet.public_subnet.*.id}"
}

output "security_group" {
  value = "${aws_security_group.test_sg.id}"
}
output "sec1_group" {
  value = "${aws_security_group.test_sg.id}"
}
output "subnets" {
  value = "${aws_subnet.public_subnet.*.id}"
}


output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "subnet1" {
  value = "${element(aws_subnet.public_subnet.*.id, 1 )}"
}

output "subnet2" {
  value = "${element(aws_subnet.public_subnet.*.id, 2 )}"
}

output "private_subnet1" {
  value = "${element(aws_subnet.private_subnet.*.id, 1 )}"
}

output "private_subnet2" {
  value = "${element(aws_subnet.private_subnet.*.id, 2 )}"
}


output "check_eip" {
    value  = aws_eip.my-test-eip.id
}

# output "sec1_group" {
#   value =  "${aws_secutiry_group.test_sg.id}"
# }