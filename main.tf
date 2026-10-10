# ------------------------------------------------------------------------------
# 1. VIRTUAL PRIVATE CLOUD (VPC)
# ------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# ------------------------------------------------------------------------------
# 2. INTERNET GATEWAY
# ------------------------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# ------------------------------------------------------------------------------
# 3. SUBNETS (MULTI-AZ: PUBLIC & PRIVATE)
# ------------------------------------------------------------------------------
# Public Subnets (Tier 1: Web / Ingress)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
    Tier = "Public"
    AZ   = var.availability_zones[count.index]
  }
}

# Private Subnets (Tier 2: Backend & Database Isolation)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
    Tier = "Private"
    AZ   = var.availability_zones[count.index]
  }
}

# ------------------------------------------------------------------------------
# 4. ROUTE TABLES & ASSOCIATIONS
# ------------------------------------------------------------------------------
# Public Route Table (Outbound Internet Egress via IGW)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-public-route-table"
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table (Isolated Internal Routing)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-private-route-table"
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# ------------------------------------------------------------------------------
# 5. DEFENSE-IN-DEPTH: MULTI-TIER SECURITY GROUPS
# ------------------------------------------------------------------------------
# Web Tier Security Group (Public HTTP/HTTPS)
resource "aws_security_group" "web_sg" {
  name        = "${var.environment}-web-tier-sg"
  description = "Allows inbound HTTP/HTTPS traffic to web services"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-web-tier-sg"
  }
}

# Database Tier Security Group (Restricted: ONLY accessible by Web Tier SG)
resource "aws_security_group" "db_sg" {
  name        = "${var.environment}-db-tier-sg"
  description = "Strict least-privilege: Allows database access ONLY from web tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow MySQL/Aurora only from Web Tier SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-db-tier-sg"
  }
}
