provider "aws" {
  region = var.region
}

resource "aws_security_group" "launch-wizard-1" {
  name        = "${var.project_name}-sg"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
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

resource "aws_instance" "app_server" {
  ami           = "ami-0f918f7e67a3323f0" # Replace with valid AMI for your region
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.launch-wizard-1.id]

  user_data = file("${path.module}/userdata.sh")

  tags = {
    Name = var.project_name
  }
}
