locals {
  use_managed_role = var.create_role
}

# Optional role creation (least-privilege for S3 + basic logging)
data "aws_iam_policy_document" "assume_lambda" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "s3_rw" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.target_bucket}",
      "arn:aws:s3:::${var.target_bucket}/*"
    ]
  }
}

resource "aws_iam_role" "lambda" {
  count              = local.use_managed_role ? 1 : 0
  name               = coalesce(var.role_name, "${var.lambda_function_name}-role")
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
  tags               = var.tags
}

resource "aws_iam_policy" "s3_rw" {
  count  = local.use_managed_role ? 1 : 0
  name   = "${var.lambda_function_name}-s3-rw"
  policy = data.aws_iam_policy_document.s3_rw.json
}

resource "aws_iam_role_policy_attachment" "basic_exec" {
  count      = local.use_managed_role ? 1 : 0
  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_rw" {
  count      = local.use_managed_role ? 1 : 0
  role       = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.s3_rw[0].arn
}

# Lambda function
resource "aws_lambda_function" "writer" {
  function_name    = var.lambda_function_name
  role             = var.create_role ? aws_iam_role.lambda[0].arn : var.role_arn
  runtime          = var.lambda_runtime
  handler          = "writer.lambda_handler"
  filename         = "${path.root}/../terraform-modules/lambda_writer/app.zip"
  source_code_hash = filebase64sha256("${path.root}/../terraform-modules/lambda_writer/app.zip")

  architectures = [var.lambda_architecture]
  memory_size   = var.lambda_memory_size
  timeout       = var.lambda_timeout

  environment {
    variables = merge({ BUCKET = var.target_bucket }, var.lambda_environment)
  }

  tags = var.tags
}

# Log group (explicit to control retention)
resource "aws_cloudwatch_log_group" "lg" {
  name              = "/aws/lambda/${aws_lambda_function.writer.function_name}"
  retention_in_days = var.lambda_log_retention_days
  tags              = var.tags
}

# Optional schedule (EventBridge -> Lambda)
resource "aws_cloudwatch_event_rule" "schedule" {
  count               = var.lambda_schedule_expression == null ? 0 : 1
  name                = "${var.lambda_function_name}-schedule"
  schedule_expression = var.lambda_schedule_expression
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "t" {
  count     = var.lambda_schedule_expression == null ? 0 : 1
  rule      = aws_cloudwatch_event_rule.schedule[0].name
  target_id = "lambda"
  arn       = aws_lambda_function.writer.arn
}

resource "aws_lambda_permission" "allow_events" {
  count         = var.lambda_schedule_expression == null ? 0 : 1
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.writer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule[0].arn
}
