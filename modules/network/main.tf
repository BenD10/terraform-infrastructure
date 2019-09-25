resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  tags = {
    Name = "Production VPC"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
  tags = {
    Name = "Production Internet Gateway"
  }
}

# Get an EIP for the NAT gateway
resource "aws_eip" "default" {
  tags = {
    Name = "Production NAT EIP"
  }
}

# Create two route tables, one that allows for internet access and one that doesn't.
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_internet_gateway.default.id}"
  }
  tags = {
    Name = "Public Subnet Route Table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.default.id}"
  tags = {
    Name = "Private Subnet Route Table"
  }
}

# Get the available AZs, we don't care which ones.
data "aws_availability_zones" "available" {
  state = "available"
}

# Create public subnets, which will have an NAT gateway associated with them.
# Normally used for app servers behind a load balancer.
resource "aws_subnet" "public_subnets" {
  count = "${length(var.public_subnet_cidrs)}"

  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${element(var.public_subnet_cidrs, count.index)}"
  tags = {
    Name = "public_subnet_${count.index}"
  }
}

resource "aws_route_table_association" "public_subnets" {
  count = "${length(var.public_subnet_cidrs)}"

  subnet_id      = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

# Create private subnets, which will have no Internet access.
# Typical for databases.
resource "aws_subnet" "private_subnets" {
  count = "${length(var.private_subnet_cidrs)}"

  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${element(var.private_subnet_cidrs, count.index)}"
  tags = {
    Name = "private_subnet_${count.index}"
  }
}

resource "aws_route_table_association" "private_subnets" {
  count = "${length(var.private_subnet_cidrs)}"

  subnet_id      = "${element(aws_subnet.private_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}
