provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "booker_avatars" {
  bucket = "booker-avatars"
}

resource "aws_lambda_function" "booker-avatar" {
  function_name = "booker_avatar"

  s3_bucket = "booker-avatar"
  s3_key    = "v1.0.0/example.zip"

  handler = "main.handler"
  runtime = "nodejs8.10"

  environment {
    variables = {
      BUCKET = "${aws_s3_bucket.booker_avatars.bucket}"
    }
  }

  role = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda_exec" {
  name = "booker-avatar-lambda"

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

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = "${aws_iam_role.lambda_exec.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

resource "aws_s3_bucket_notification" "booker_avatars_notification" {
  bucket = "${aws_s3_bucket.booker_avatars.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.booker-avatar.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.booker-avatar.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.booker_avatars.arn}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.booker-avatar.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.booker_avatar_deployment.execution_arn}/*/*"
}
