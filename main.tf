/*resource "aws_vpc" "my_vpc"{
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
}*/
data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}



module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_instance" "blog"{
    ami = data.aws_ami.app_ami.id
    instance_type = var.instance_type 

    subnet_id = module.blog_vpc.public_subnets[0]

    vpc_security_group_ids = [module.blog_sg.security_group_id]

    tags = {
        Name = "HelloWorld"
    }
}


/*module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "8.2.0"
  # insert the 1 required variable here
  name =  "blog"
  min_size = 1
  max_size = 2

  vpc_zone_identifier = module.blog_vpc.public_subnets
  target_group_arn    =   module.blog_alb.target_group_arns[0]
  security_groups = [module.blog_sg.security_group_id]

  image_id = data.aws_ami.app_ami.id
  instance_type = var.instance_type 
}*/

module "blog_alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "blog-alb"
  vpc_id  = module.blog_vpc.vpc_id
  subnets = module.blog_vpc.public_subnets
  security_groups = [module.blog_sg.security_group_id]


  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    
  }

  target_groups = {
    instance = {
      name_prefix      = "blog"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"      
      target_id = aws_instance.blog.id

    }  
   }

  



  tags = {
    Environment = "dev"
    
  }
}


module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"
  name = "blog_new"
  vpc_id = module.blog_vpc.vpc_id


  ingress_rules =["http-80-tcp","https-443-tcp"]
  ingress_cidr_blocks =["0.0.0.0/0"]

  egress_rules =["http-80-tcp","https-443-tcp"]
  egress_cidr_blocks =["0.0.0.0/0"]


}

