provider "aws" {
  region = "us-east-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable instance_type {}
variable public_key_location {}

resource "aws_vpc" "main_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "main_subnet" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet"
    }
}

resource "aws_internet_gateway" "app-igw" {
    vpc_id = aws_vpc.main_vpc.id
    tags = {
        Name = "${var.env_prefix}-igw"
    }
}

resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.main_vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.app-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-main-rtb"
    }
}

resource "aws_route_table_association" "rta" {
    subnet_id  = aws_subnet.main_subnet.id
    route_table_id = aws_default_route_table.main-rtb.id

}


resource "aws_security_group" "app-sg" {
    vpc_id = aws_vpc.main_vpc.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 5000
        to_port     = 5001
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name = "${var.env_prefix}-app-sg"
    }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}


resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = file(var.public_key_location)
}

resource "aws_instance" "ServiceA" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.main_subnet.id
    vpc_security_group_ids = [aws_security_group.app-sg.id]
    availability_zone = var.avail_zone

    key_name = aws_key_pair.ssh-key.key_name
    iam_instance_profile = aws_iam_instance_profile.cw_profile.name

    user_data = file("setup.sh")

    tags = {
        Name = "${var.env_prefix}-VMA"
    }
}

resource "aws_instance" "ServiceB" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.main_subnet.id
    vpc_security_group_ids = [aws_security_group.app-sg.id]
    availability_zone = var.avail_zone

    key_name = aws_key_pair.ssh-key.key_name
    iam_instance_profile = aws_iam_instance_profile.cw_profile.name

    user_data = file("setup.sh")

    tags = {
        Name = "${var.env_prefix}-VMB"
    }
}

resource "aws_iam_role" "ec2_cloudwatch" {
  name = "ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cw_attach" {
  role       = aws_iam_role.ec2_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "cw_profile" {
  name = "ec2-cw-profile"
  role = aws_iam_role.ec2_cloudwatch.name
}
resource "aws_eip" "service_a_eip" {
  depends_on = [aws_internet_gateway.app-igw]
}

resource "aws_eip" "service_b_eip" {
  depends_on = [aws_internet_gateway.app-igw]
}
resource "aws_eip_association" "service_a_eip_assoc" {
  instance_id   = aws_instance.ServiceA.id
  allocation_id = aws_eip.service_a_eip.id
}

resource "aws_eip_association" "service_b_eip_assoc" {
  instance_id   = aws_instance.ServiceB.id
  allocation_id = aws_eip.service_b_eip.id
}

