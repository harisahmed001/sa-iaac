resource "aws_vpc" "vpc_main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name}-tf-vpc"
  }
}


resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.public_availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-tf-public-subnet-1"
    Tier = "public"

  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.public_availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name                                = "${var.name}-tf-public-subnet-2"
    Tier                                = "public"
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/elb"            = "1"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.private_availability_zone

  tags = {
    Name                                = "${var.name}-tf-private-subnet-1"
    Tier                                = "private"
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"   = "1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.private_availability_zone_2

  tags = {
    Name = "${var.name}-tf-private-subnet-2"
    Tier = "private"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "${var.name}-tf-gw"
  }
}


resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.name}-tf-private-rt"
  }
}

resource "aws_default_route_table" "default_public_rt" {
  default_route_table_id = aws_vpc.vpc_main.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.name}-tf-public-rt"
  }
}


resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.vpc_main.default_network_acl_id
  subnet_ids             = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
  egress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }

  ingress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }
  tags = {
    Name = "${var.name}-tf-public-nacl"
  }
}


resource "aws_network_acl" "main" {
  vpc_id     = aws_vpc.vpc_main.id
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_2.id]

  egress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }

  ingress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }

  tags = {
    Name = "${var.name}-tf-private-nacl"
  }
}


resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_default_route_table.default_public_rt.id
}


resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_default_route_table.default_public_rt.id
}


resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}


resource "aws_eip" "nat_eip" {
  tags = {
    Name = "${var.name}-tf-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "${var.name}-tf-nat-gw"
  }
}


resource "aws_security_group" "vpc_sg" {
  name        = "${var.name}-tf-vpc-all-allowed-sg"
  description = "Allow all ports, just for testing"
  vpc_id      = aws_vpc.vpc_main.id

  ingress {
    description = "Allowing all ports"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.name}-tf-vpc-all-allowed-sg"
  }
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id       = aws_vpc.vpc_main.id
  service_name = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    aws_security_group.vpc_sg.id
  ]
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_2.id]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id                       = aws_vpc.vpc_main.id
  service_name                 = "com.amazonaws.${var.region}.s3"
  route_table_ids              = [aws_route_table.private_rt.id]
}
