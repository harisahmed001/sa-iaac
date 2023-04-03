resource "aws_security_group" "vpc_sg" {
  name        = "${var.name}-tf-http"
  description = "Allow port 80"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "Allowing port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.name}-tf-http"
  }
}
