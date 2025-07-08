provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = var.subnet_availability_zone
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_block
  availability_zone = var.subnet_availability_zone
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "nlb_sg" {
  name   = "nlbSG"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "webapp_sg" {
  name   = "csyeWebAppSG"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.nlb_sg.id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "mysql_sg" {
  name   = "csyeMySQLSG"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webapp_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.webapp_sg.id]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.webapp_sg.id]
  }
}

resource "aws_security_group_rule" "allow_mysql_from_webapp" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.webapp_sg.id
  source_security_group_id = aws_security_group.mysql_sg.id
}

/*
resource "aws_vpc_endpoint" "cloudwatch_metrics" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-west-2.monitoring"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.webapp_sg.id]
  subnet_ids         = [aws_subnet.private.id]

  private_dns_enabled = true

  tags = {
    Name = "mysql-endpoint"
  }
}
*/

resource "tls_private_key" "csye6225-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "csye6225-key-pair" {
  key_name   = "csye6225-key"
  public_key = tls_private_key.csye6225-key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.csye6225-key.private_key_pem
  filename        = "csye6225-key.pem"
  file_permission = "0600"
}

resource "aws_instance" "mysql_instance" {
  ami                    = var.mysql_ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.csye6225-key-pair.key_name
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "wait_for_mysql_instance" {
  depends_on = [aws_instance.mysql_instance]

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.mysql_instance.id}"
  }
}

resource "aws_volume_attachment" "mysql_volume_attachment" {
  device_name = "/dev/sdf"
  instance_id = aws_instance.mysql_instance.id
  volume_id   = "vol-00363ba4d795d7a92"
}

resource "aws_instance" "webapp_instance" {
  count                  = 3
  ami                    = var.webapp_ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.csye6225-key-pair.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.webapp_sg.id]

  user_data = templatefile("${path.module}/scripts/setup_webapp.sh", {
    MYSQL_PRIVATE_IP  = aws_instance.mysql_instance.private_ip
    DATABASE_USERNAME = var.database_username
    DATABASE_PASSWORD = var.database_password
  })

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "webapp-instance-${count.index + 1}"
  }
}

resource "null_resource" "wait_for_webapp_instance" {
  depends_on = [aws_instance.webapp_instance]

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${join(" ", aws_instance.webapp_instance[*].id)}"
  }
}

resource "null_resource" "create_secrets_directory" {
  depends_on = [null_resource.wait_for_webapp_instance]

  count = 3

  connection {
    type        = "ssh"
    host        = aws_instance.webapp_instance[count.index].public_ip
    user        = "ubuntu"
    private_key = local_file.private_key.content
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/secrets"
    ]
  }
}

resource "null_resource" "transfer_secrets" {
  depends_on = [null_resource.create_secrets_directory]

  count = 3

  connection {
    type        = "ssh"
    host        = aws_instance.webapp_instance[count.index].public_ip
    user        = "ubuntu"
    private_key = local_file.private_key.content
  }

  provisioner "file" {
    content     = var.database_username
    destination = "/home/ubuntu/secrets/database_username.txt"
  }

  provisioner "file" {
    content     = var.database_password
    destination = "/home/ubuntu/secrets/database_password.txt"
  }

  provisioner "file" {
    content     = aws_instance.mysql_instance.private_ip
    destination = "/home/ubuntu/secrets/mysql_private_ip.txt"
  }

  provisioner "file" {
    content     = aws_instance.webapp_instance[count.index].public_ip
    destination = "/home/ubuntu/secrets/webapp_private_ip.txt"
  }

  provisioner "file" {
    content     = local_file.private_key.content
    destination = "/home/ubuntu/secrets/ec2_key.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/secrets/ec2_key.pem"
    ]
  }
}

resource "null_resource" "create_scripts_directory" {
  depends_on = [null_resource.wait_for_webapp_instance]

  count = 3

  connection {
    type        = "ssh"
    host        = aws_instance.webapp_instance[count.index].public_ip
    user        = "ubuntu"
    private_key = local_file.private_key.content
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/scripts"
    ]
  }
}

resource "null_resource" "setup_mysql_ebs" {
  depends_on = [null_resource.transfer_secrets]

  count = 3

  connection {
    type        = "ssh"
    host        = aws_instance.webapp_instance[count.index].public_ip
    user        = "ubuntu"
    private_key = local_file.private_key.content
  }

  provisioner "file" {
    source      = "scripts/setup_mysql_ebs.sh"
    destination = "/home/ubuntu/scripts/setup_mysql_ebs.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/scripts/setup_mysql_ebs.sh",
      "bash /home/ubuntu/scripts/setup_mysql_ebs.sh"
    ]
  }
}

resource "null_resource" "update_mysql_bind_address" {
  depends_on = [null_resource.setup_mysql_ebs]

  count = 3

  connection {
    type        = "ssh"
    host        = aws_instance.webapp_instance[count.index].public_ip
    user        = "ubuntu"
    private_key = local_file.private_key.content
  }

  provisioner "file" {
    source      = "scripts/update_mysql_bind_address.sh"
    destination = "/home/ubuntu/scripts/update_mysql_bind_address.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/scripts/update_mysql_bind_address.sh",
      "bash /home/ubuntu/scripts/update_mysql_bind_address.sh"
    ]
  }
}

resource "null_resource" "verify_connection_and_setup_database" {
  depends_on = [null_resource.update_mysql_bind_address]

  count = 3

  connection {
    type        = "ssh"
    host        = aws_instance.webapp_instance[count.index].public_ip
    user        = "ubuntu"
    private_key = local_file.private_key.content
  }

  provisioner "file" {
    source      = "scripts/setup_database.sh"
    destination = "/home/ubuntu/scripts/setup_database.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/scripts/setup_database.sh",
      "bash /home/ubuntu/scripts/setup_database.sh"
    ]
  }
}

resource "aws_lb" "api_nlb" {
  name                       = "api-nlb"
  internal                   = false
  load_balancer_type         = "network"
  security_groups            = [aws_security_group.nlb_sg.id]
  subnets                    = [aws_subnet.public.id]
  enable_deletion_protection = false
  ip_address_type            = "ipv4"
}

resource "aws_lb_target_group" "nlb_tg01" {
  name     = "nlb-tg01"
  port     = 8080
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/v1/healthcheck"
    protocol            = "HTTP"
    timeout             = 4
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.api_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg01.arn
  }
}

resource "aws_lb_target_group_attachment" "nlb_tg_attachment" {
  count            = 3
  target_group_arn = aws_lb_target_group.nlb_tg01.arn
  target_id        = aws_instance.webapp_instance[count.index].id
  port             = 8080
}