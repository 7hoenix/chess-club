provider "aws" {
  region = "us-west-1"
}

resource "aws_security_group" "chess_club" {
  name          = "allow-all-sg"
  description   = "Allow all inbound ssh+http traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "chess_club" {
  key_name   = "chess_club_depley"
  public_key = file("../chess_club_key.pub")
}

resource "aws_instance" "chess_club" {
  ami             = "ami-0418d0e1b0321f723"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.chess_club.key_name
  security_groups = [aws_security_group.chess_club.name]
}

output "webhook_processor_host" {
  value = aws_instance.chess_club.public_dns
}
