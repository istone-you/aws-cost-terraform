data "aws_caller_identity" "current" {}

resource "aws_cur_report_definition" "cur_report" {
  report_name                = "cur-report-${data.aws_caller_identity.current.account_id}"
  time_unit                  = "HOURLY"
  format                     = "Parquet"
  compression                = "Parquet"
  additional_schema_elements = ["RESOURCES"]
  s3_bucket                  = aws_s3_bucket.cur_report.id
  s3_region                  = "us-east-1"
  s3_prefix                  = "${data.aws_caller_identity.current.account_id}/CostAndUsageReport"
  additional_artifacts       = ["ATHENA"]
  report_versioning          = "OVERWRITE_REPORT"
}

resource "aws_s3_bucket" "cur_report" {
  bucket = "cur-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "cur-${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cur_report_encryption" {
  bucket = aws_s3_bucket.cur_report.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.key_s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "cur_report" {
  bucket = aws_s3_bucket.cur_report.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.cur_report.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.cur_report.arn,
          "${aws_s3_bucket.cur_report.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_kms_key" "key_s3" {
  description = "ECS pipeline artifact Key"
  is_enabled  = true
  policy      = data.aws_iam_policy_document.key_s3.json
  key_usage   = "ENCRYPT_DECRYPT"
  tags = {
    Name = "cur_report-s3-key"
  }
}

resource "aws_kms_alias" "key_alias_s3" {
  name          = "alias/cur_report-s3-key"
  target_key_id = aws_kms_key.key_s3.key_id
}

data "aws_iam_policy_document" "key_s3" {
  version = "2012-10-17"
  # デフォルトキーポリシー
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}
