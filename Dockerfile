provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "workshop" {
  cidr_block = "172.1.0.0/24"
  tags = {
    "Name" = "workshop_VPC"
  }
}
resource "aws_subnet" "public_Az1" {
    vpc_id     = aws_vpc.workshop.id
    availability_zone = "us-east-1a"
    cidr_block = "172.1.0.0/27"
    map_public_ip_on_launch = true
    tags = {
      "Name" = "public_subnet"
    }  
}
resource "aws_subnet" "public-Az2" {
    vpc_id     = aws_vpc.workshop.id
    availability_zone = "us-east-1b"
    cidr_block = "172.1.0.32/27"
    map_public_ip_on_launch = true
    tags = {
      "Name" = "public_subnet"
    }  
}

resource "aws_subnet" "private1_Az1" {
    vpc_id     = aws_vpc.workshop.id
    availability_zone = "us-east-1a" 
    cidr_block = "172.1.0.64/26"
    map_public_ip_on_launch = false
    tags = {
      "Name" = "private_subnet"
    }  
}    
resource "aws_subnet" "private1_Az2" {
    vpc_id     = aws_vpc.workshop.id
    availability_zone = "us-east-1b" 
    cidr_block = "172.1.0.128/26"
    map_public_ip_on_launch = false
    tags = {
      "Name" = "private_subnet"
    }  
} 
resource "aws_subnet" "private2_Az1" {
    vpc_id     = aws_vpc.workshop.id
    availability_zone = "us-east-1a"
    cidr_block = "172.1.0.192/27"
    map_public_ip_on_launch = false
    tags = {
      "Name" = "private_subnet"
    }      
}
resource "aws_subnet" "private2_Az2" {
    vpc_id     = aws_vpc.workshop.id
    availability_zone = "us-east-1b"
    cidr_block = "172.1.0.224/27"
    map_public_ip_on_launch = false
    tags = {
      "Name" = "private_subnet"
    }      
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.workshop.id
  tags = {
    Name        = "public_IGW"
    
  }
}
/*
resource "aws_route_table" "route_table" {
  
}
resource "aws_route" "public_internet_gateway_route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}
*/
resource "aws_eip" "nat_eip1" {
  vpc        = true
}
resource "aws_eip" "nat_eip2" {
  vpc        = true
}
resource "aws_nat_gateway" "ngw_AZ1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.public_Az1.id

  tags = {
    Name        = "workshop_nat_Az1"
    
  }
}
resource "aws_nat_gateway" "ngw_Az2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.public-Az2.id

  tags = {
    Name        = "workshop_nat_Az2"
    
  }
}
/*
resource "aws_key_pair" "workspace_key" {
    key_name = "workshop"
    public_key = tls_private_key.example.public_key_openssh
  
}
*/
module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = "workshop"
  create_private_key = true
}
resource "aws_security_group" "public_sg" {
  vpc_id      = aws_vpc.workshop.id
  ingress {
    description      = "TLS from public internet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.workshop.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "public-subnet_sg"
  }
}
resource "aws_network_interface" "pub1" {
  subnet_id   = aws_subnet.public_Az1.id
  security_groups = [ "sg-02ff6805af2151d1c" ] 
  private_ips = ["172.1.0.10"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "bastion_instance" {
  ami           = "ami-08c40ec9ead489470" # us-east-1a
  instance_type = "t2.micro"
  key_name = "workshop"
  availability_zone = "us-east-1a"
  #security_groups = [ "sg-02ff6805af2151d1c" ] 
  tags = {
    "name" = "bastion_instance"
  }
  #vpc_security_group_ids = aws_security_group.public_sg.id

  network_interface {
    network_interface_id = aws_network_interface.pub1.id
    device_index         = 0
  }
  
}  
/*

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.workshop.id
    tags = {
        "Name" = "Public_route"
    }
  
}
resource "aws_route_table_association" "public" {
  
  subnet_id      = "subnet-07ae6dc188a79629e"
  route_table_id = "rtb-086d212903009cfc4"
}
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.workshop.id
    tags = {
        "Name" = "Private_route"
    }
  
}
resource "aws_route_table_association" "private" {
  
  subnet_id      = "subnet-01213d44285994081"
  route_table_id = "rtb-086d212903009cfc4"
}
resource "aws_nat_gateway" "nat" {
  allocation_id = "eipalloc-006b7983e45b9f09a"
  subnet_id     = "subnet-01213d44285994081"

  tags = {
    Name        = "Private_nat"
    
  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
*/
