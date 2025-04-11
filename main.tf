resource "aws_vpc" "my_vpc"{
    cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.0.0/25"
    map_public_ip_on_launch = true
    availability_zone =  "us-west-2b"  
}

resource "aws_internet_gateway" "igw"{
    vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_route"{
    vpc_id = aws_vpc.my_vpc.id
    
}

resource "aws_route" "public-route-table"{
    route_table_id =aws_route_table.my_route.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

}

resource "aws_route_table_association"  "public_rta"{
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route.public-route-table.id
}

resource "aws_security_group" "ec2_sg"{
    name = "ec2_sg"
    description = "security group for EC2 machines"
    vpc_id  = aws_vpc.my_vpc.id
    ingress{
        description = "SSH connectivity"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port =0
        to_port = 0
        protocol ="-1"
        cidr_blocks = ["0.0.0.0/0"]
}

