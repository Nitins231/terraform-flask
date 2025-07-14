provider "aws" {
  region = "ap-south-1"  # Choose your preferred region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.r.id
}

# Security Group
resource "aws_security_group" "allow_web" {
  name        = "flask-express-sg"
  description = "Allow web and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # open Flask
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # open Express
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Flask EC2 instance
resource "aws_instance" "flask" {
  ami                    = "ami-0f5ee92e2d63afc18"  # Ubuntu 22.04 in ap-south-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  associate_public_ip_address = true
  key_name               = var.key_name

  user_data = file("${path.module}/userdata-flask.sh")

  tags = {
    Name = "FlaskApp"
  }
}

# Express EC2 instance
resource "aws_instance" "express" {
  ami                    = "ami-0f5ee92e2d63afc18"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  associate_public_ip_address = true
  key_name               = var.key_name

user_data_base64 = base64encode(templatefile("${path.module}/userdata-express.sh.tpl", {
  flask_private_ip = aws_instance.flask.private_ip
  port             = 3000
}))

  tags = {
    Name = "ExpressApp"
  }
}
