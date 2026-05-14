resource "aws_security_group" "public_ssh" {
  name        = "checkov-test-public-ssh"
  description = "Intentionally insecure security group for Checkov testing"

  ingress {
    description = "SSH open to the world - Checkov should fail this"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP open to the world"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic allowed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "checkov-test-insecure-bucket-123456789"

  tags = {
    Environment = "dev"
    Purpose     = "checkov-testing"
  }
}

resource "aws_s3_bucket_public_access_block" "bad_public_access" {
  bucket = aws_s3_bucket.insecure_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "disabled_versioning" {
  bucket = aws_s3_bucket.insecure_bucket.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_policy" "public_read_bucket_policy" {
  bucket = aws_s3_bucket.insecure_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.insecure_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_ssm_parameter" "hardcoded_password" {
  name        = "/checkov-test/db-password"
  description = "Intentionally insecure hardcoded password for scanner testing"
  type        = "String"
  value       = "P@ssw0rd123!"
}

resource "aws_db_instance" "insecure_db" {
  identifier              = "checkov-test-insecure-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "checkovdb"
  username                = "admin"
  password                = "P@ssw0rd123!"
  publicly_accessible     = true
  storage_encrypted       = false
  backup_retention_period = 0
  deletion_protection     = false
  skip_final_snapshot     = true

  vpc_security_group_ids = [aws_security_group.public_ssh.id]
}


