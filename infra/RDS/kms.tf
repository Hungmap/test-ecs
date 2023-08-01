data "aws_kms_key" "by-aws" {
  key_id = "arn:aws:kms:ap-northeast-1:723865550634:key/c73f2c1c-d2f8-4500-b7b7-72d2c8a1e621"
}
resource "aws_secretsmanager_secret" "db" {
  name = "pass_db"
  description = "this is store password db "
  kms_key_id = data.aws_kms_key.by-aws.id

}
resource "aws_secretsmanager_secret_policy" "allow_access_secret" {
  secret_arn = aws_secretsmanager_secret.db.arn
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnableAnotherAWSAccountToReadTheSecret",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:root"
      },
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "*"
    }
  ]
}
POLICY
}
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_lambda_function" "rotation" {
  filename = "rotation.py"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  #source_code_hash = filebase64sha256("rotation.py")

  runtime = "python3.9"

  environment {
    variables = {
      foo = "bar"
    }
  }
}
  

resource "aws_secretsmanager_secret_rotation" "default" {
  secret_id = aws_secretsmanager_secret.db.id
  rotation_lambda_arn = aws_lambda_function.rotation.arn

  rotation_rules {
    automatically_after_days = 30
  }
  
}