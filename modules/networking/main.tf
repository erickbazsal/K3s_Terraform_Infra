#networking/main.tf
data "aws_availability_zones" "available" {}
resource "random_integer" "random" {
  min = 1
  max = 9
}
resource "random_string" "random2" {
  length  = 5
  special = false
  number  = false
}
resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}
resource "aws_vpc" "bazan_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "bazan_vpc-${random_integer.random.id}${random_string.random2.id}"
  }
  lifecycle {
    create_before_destroy = true #for resources being updated, since the original reosurce is being destroyed it will hang there
  }
}
resource "aws_subnet" "Bazan_public_subnet" {
  #count = length(var.public_cidrs)
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.bazan_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  #availability_zone = data.aws_availability_zones.available.names[count.index] #using data source attribute
  availability_zone = random_shuffle.az_list.result[count.index]
  tags = {
    Name = "Bazan_public_${count.index + 1}"
  }
}
resource "aws_subnet" "Bazan_private_subnet" {
  #count = length(var.private_cidrs)
  count      = var.private_sn_count
  vpc_id     = aws_vpc.bazan_vpc.id
  cidr_block = var.private_cidrs[count.index]
  #availability_zone = data.aws_availability_zones.available.names[count.index]
  availability_zone = random_shuffle.az_list.result[count.index]
  tags = {
    Name = "Bazan_private_${count.index + 1}"
  }
}
resource "aws_internet_gateway" "bazan_internet_gateway" {
  vpc_id = aws_vpc.bazan_vpc.id
  tags   = local.common_tags
}
resource "aws_route_table" "Bazan_public_rt" {
  vpc_id = aws_vpc.bazan_vpc.id
  tags = merge(local.common_tags,
    map(
      "Name", "Bazan_public_RT"
    )
  )
}
resource "aws_route_table_association" "bazan_public_assoc" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.Bazan_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.Bazan_public_rt.id
}
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.Bazan_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.bazan_internet_gateway.id
}

resource "aws_default_route_table" "bazan_private_rt" {
  default_route_table_id = aws_vpc.bazan_vpc.default_route_table_id #using existing routetable id,created by the VPC
  tags = merge(local.common_tags,
    map(
      "Name", "Bazan_private_RT"
    )
  )
}


resource "aws_security_group" "bazan_sg" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.bazan_vpc.id
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_subnet_group" "bazan_rds_subnet_group" {
  count = var.db_subnet_group == true ? 1 : 0
  #abb count = var.db_subnet_group  ? 1 : 0
  name       = "bazan_rds_subnetgroup"
  subnet_ids = aws_subnet.Bazan_private_subnet.*.id
  tags = merge(local.common_tags,
    map(
      "Name", "bazan_rds_SnG"
    )
  )
}