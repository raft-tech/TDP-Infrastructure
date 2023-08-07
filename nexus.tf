resource "aws_instance" "nexus_server" {
  ami                         = data.aws_ami.docker_server.id
  instance_type               = "t3.medium"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = module.base_network.public_subnets_ids[0]
  vpc_security_group_ids      = [aws_security_group.nexus.id]

  user_data = "${file("nexus_user_data.sh")}"

  root_block_device {
    delete_on_termination = true
    volume_size           = 40
    tags = {
      Name = "Nexus Storage"
    }
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "Nexus Server"
  }
}