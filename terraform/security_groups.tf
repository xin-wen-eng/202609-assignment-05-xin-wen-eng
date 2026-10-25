resource "aws_security_group" "bastion_sg" {
  name        = "assignment5-bastion-sg"
  description = "Bastion: SSH/HTTP from the internet, SSH/HTTP out to the private subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Private subnet CIDR (not private_sg) to avoid a security group cycle.
  egress {
    description = "SSH to private subnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.20.2.0/24"]
  }

  egress {
    description = "HTTP to private subnet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["172.20.2.0/24"]
  }

  tags = {
    Name = "assignment5-bastion-sg"
  }
}

# No egress: the private host never initiates connections, and SGs are stateful.
resource "aws_security_group" "private_sg" {
  name        = "assignment5-private-sg"
  description = "Private host: SSH/HTTP only from the bastion security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from bastion SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description     = "HTTP from bastion SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  tags = {
    Name = "assignment5-private-sg"
  }
}
