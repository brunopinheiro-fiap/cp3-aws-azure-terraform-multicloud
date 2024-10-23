# Criar VPC10 (Pública)
resource "aws_vpc" "vpc10" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC10-Public"
  }
}

# Criar VPC20 (Privada)
resource "aws_vpc" "vpc20" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC20-Private"
  }
}

# Internet Gateway para VPC10 (Pública)
resource "aws_internet_gateway" "igw_vpc10" {
  vpc_id = aws_vpc.vpc10.id
  tags = {
    Name = "IGW-VPC10"
  }
}

# Subnet Pública na VPC10
resource "aws_subnet" "subnet10a" {
  vpc_id                  = aws_vpc.vpc10.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet10a"
  }
}

# Subnet Privada na VPC20
resource "aws_subnet" "subnet20a" {
  vpc_id            = aws_vpc.vpc20.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "PrivateSubnet20a"
  }
}

# Route Table para Subnet Pública (VPC10)
resource "aws_route_table" "route_table_vpc10" {
  vpc_id = aws_vpc.vpc10.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc10.id
  }
  tags = {
    Name = "PublicRouteTable-VPC10"
  }
}

# Associação da Subnet Pública à Tabela de Rotas (VPC10)
resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.subnet10a.id
  route_table_id = aws_route_table.route_table_vpc10.id
}

# Peering entre VPC10 e VPC20
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id        = aws_vpc.vpc10.id
  peer_vpc_id   = aws_vpc.vpc20.id
  auto_accept   = true
  peer_region   = "us-east-1"
  tags = {
    Name = "VPC10-to-VPC20-Peering"
  }
}

# Rotas para VPC Peering (VPC10 -> VPC20)
resource "aws_route" "vpc10_to_vpc20_route" {
  route_table_id         = aws_route_table.route_table_vpc10.id
  destination_cidr_block = aws_vpc.vpc20.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

# Rotas para VPC Peering (VPC20 -> VPC10)
resource "aws_route_table" "route_table_vpc20" {
  vpc_id = aws_vpc.vpc20.id
  route {
    cidr_block                = aws_vpc.vpc10.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }
  tags = {
    Name = "PrivateRouteTable-VPC20"
  }
}

# Associação da Subnet Privada à Tabela de Rotas (VPC20)
resource "aws_route_table_association" "private_route_association" {
  subnet_id      = aws_subnet.subnet20a.id
  route_table_id = aws_route_table.route_table_vpc20.id
}