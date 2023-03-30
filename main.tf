data "aws_caller_identity" "current" {}

resource "aws_cur_report_definition" "cur_report" {
  report_name                = "cur-report-${data.aws_caller_identity.current.account_id}"
  time_unit                  = "HOURLY"
  format                     = "Parquet"
  compression                = "Parquet"
  additional_schema_elements = ["RESOURCES"]
  s3_bucket                  = aws_s3_bucket.cur_report.id
  s3_region                  = "ap-northeadt-1"
  additional_artifacts       = ["ATHENA"]
  report_versioning          = "OVERWRITE_REPORT"
}