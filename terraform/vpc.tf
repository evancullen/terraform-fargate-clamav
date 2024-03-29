# Networking for Fargate
# Note: 10.0.0.0 and 10.0.2.0 are private IPs
# Required via https://stackoverflow.com/a/66802973/1002357
# """
# > Launch tasks in a private subnet that has a VPC routing table configured to route outbound 
# > traffic via a NAT gateway in a public subnet. This way the NAT gateway can open a connection 
# > to ECR on behalf of the task.
# """
# If this networking configuration isn't here, this error happens in the ECS Task's "Stopped reason":
# ResourceInitializationError: unable to pull secrets or registry auth: pull command failed: : signal: killed
resource "aws_vpc" "clamav_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.clamav_vpc.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.clamav_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.clamav_vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.clamav_vpc.id
}

resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_subnet" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat" {}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.clamav_vpc.id
}

resource "aws_nat_gateway" "ngw" {
  subnet_id     = aws_subnet.public.id
  allocation_id = aws_eip.nat.id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_ngw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}


resource "aws_security_group" "egress-all" {
  name        = "egress_all"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.clamav_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}