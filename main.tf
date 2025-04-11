resource "aws_vpc" "my_vpc"{
    cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.0.0/25"
    map_public_ip_on_launch = true
    availability_zone =  "us-west-2b"  
}
