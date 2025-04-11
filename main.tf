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
