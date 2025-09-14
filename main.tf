# S3 Bucket for Input Data
resource "aws_s3_bucket" "input_bucket-s3" {
  bucket = "${var.bucket_prefix}-input"
}

# S3 Bucket for Output Data
resource "aws_s3_bucket" "output_bucket-s3" {
  bucket = "${var.bucket_prefix}-output"
}

# S3 Bucket for Glue Scripts
resource "aws_s3_bucket" "scripts_s3_bucket" {
  bucket = "${var.bucket_prefix}-scripts"
}

# Upload ETL Script to S3
resource "aws_s3_object" "etl_script-s3" {
  bucket = aws_s3_bucket.scripts_s3_bucket.bucket
  key    = "etl_script.py"
  source = "etl_script.py"  # Local file path
}

# IAM Role for Glue
resource "aws_iam_role" "glue_role" {
  name = "simple-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "glue.amazonaws.com" }
    }]
  })
}

# IAM Policy for Glue (access S3)
resource "aws_iam_policy" "glue_policy" {
  name = "simple-glue-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [
          "${aws_s3_bucket.input_bucket-s3.arn}/*",
          "${aws_s3_bucket.input_bucket-s3.arn}",
          "${aws_s3_bucket.output_bucket-s3.arn}/*",
          "${aws_s3_bucket.output_bucket-s3.arn}",
          "${aws_s3_bucket.scripts_s3_bucket.arn}/*",
          "${aws_s3_bucket.scripts_s3_bucket.arn}"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["glue:*", "logs:*"]  # Basic Glue and logging
        Resource = "*"
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "glue_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}

# Glue Job
resource "aws_glue_job" "etl_job" {
  name     = var.glue_job_name
  role_arn = aws_iam_role.glue_role.arn

  command {
    script_location = "s3://${aws_s3_bucket.scripts_s3_bucket.bucket}/etl_script.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--input_bucket"                     = aws_s3_bucket.input_bucket-s3.bucket
    "--output_bucket"                    = aws_s3_bucket.output_bucket-s3.bucket
    "--continuous-log-logGroupName"      = "simple-etl-logs"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
  }

  glue_version = "4.0"  # Latest stable
  max_retries  = 0
}
