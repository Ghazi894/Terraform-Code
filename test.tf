resource "aws_vpc" "Demo" {
  cidr_block       = var.cidr_block 
  instance_tenancy = "default"

  tags = {
    Name = "Test-Vpc"
    Environment = "Test"
  }
}

resource "aws_subnet" "Public1" {
  vpc_id     = aws_vpc.Demo.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  
  tags = {
    Name = "public-1"
    Environment = "Test"
  }
}

resource "aws_subnet" "Public2" {
  vpc_id     = aws_vpc.Demo.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "public-2"
    Environment = "Test"
  }
}

resource "aws_subnet" "Private1" {
  vpc_id     = aws_vpc.Demo.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-2a"
   
  tags = {
    Name = "private-1"
    Environment = "Test"
  }
}

resource "aws_subnet" "Private2" {
  vpc_id     = aws_vpc.Demo.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-2b"
   
  tags = {
    Name = "private-2"
    Environment = "Test"
  }
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.Demo.id

  tags = {
    Name = "Test-igw"
  }
}

resource "aws_nat_gateway" "Nat1" {
  allocation_id                  = aws_eip.example.id
  subnet_id                      = aws_subnet.Public1.id
}

resource "aws_eip" "example" {
  domain   = "vpc"
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.Demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public-subnet-1-association" {
  subnet_id      = aws_subnet.Public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-subnet-2-association" {
  subnet_id      = aws_subnet.Public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.Demo.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Nat1.id
  }

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private-subnet-1-association" {
  subnet_id      = aws_subnet.Private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-subnet-2-association" {
  subnet_id      = aws_subnet.Private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_instance" "Test1" {
  ami                     = "ami-0c7217cdde317cfec"
  instance_type           = "t2.micro"
  host_resource_group_arn = "arn:aws:resource-groups:us-east-2a:012345678901:group/win-testhost"
  tenancy                 = "host"
}

resource "aws_instance" "Test2" {
  ami                     = "ami-0c7217cdde317cfec"
  instance_type           = "t2.micro"
  host_resource_group_arn = "arn:aws:resource-groups:us-east-2b:012345678901:group/win-testhost"
  tenancy                 = "host"
}
