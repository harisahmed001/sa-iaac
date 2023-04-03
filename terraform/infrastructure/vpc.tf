data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${var.name}-tf-vpc"]
  }
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Tier = "private"
  }
}

data "aws_subnet" "subnets" {
  for_each = toset(data.aws_subnets.selected.ids)
  id       = each.value
}
