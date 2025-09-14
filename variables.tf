variable "bucket_prefix" {
  description = "Prefix for S3 bucket names"
  type        = string
  default     = "aws-etl-app"  # Change this to something unique
}
variable "glue_job_name" {
  description = "Name of the Glue job"
  type        = string
  default     = "aws-etl-job"
}
