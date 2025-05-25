output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}
output "VMA_static_ip" {
  value = aws_eip.service_a_eip.public_ip
}

output "VMB_static_ip" {
  value = aws_eip.service_b_eip.public_ip
}
output "VMA_private_ip" {
  value = aws_instance.ServiceA.private_ip
}
