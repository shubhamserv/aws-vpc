resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

# Creating the first subnet
resource "aws_subnet" "sub_1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# Creating the second subnet
resource "aws_subnet" "sub_2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24" # Fixed CIDR block to avoid overlap/conflict
  availability_zone       = "us-east-1d"
  map_public_ip_on_launch = true
}

# Internet Gateway for VPC
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
}

# Route Table
resource "aws_route_table" "myroute" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub_1.id
  route_table_id = aws_route_table.myroute.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub_2.id
  route_table_id = aws_route_table.myroute.id
}

# Security Group
resource "aws_security_group" "my_sg" {
  name        = "my-sg"
  description = "Security group for Terraform project"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "my-sg"
  }

  # Egress Rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow HTTP traffic (outbound)
resource "aws_security_group_rule" "allow_http_egress" {
  type                     = "egress"
  security_group_id        = aws_security_group.my_sg.id
  cidr_blocks              = ["0.0.0.0/0"]
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
}

# Allow SSH traffic (outbound)
resource "aws_security_group_rule" "allow_ssh_egress" {
  type                     = "egress"
  security_group_id        = aws_security_group.my_sg.id
  cidr_blocks              = ["0.0.0.0/0"]
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}
