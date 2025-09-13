variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "target_bucket" {
  description = "S3 bucket the Lambda will write objects to"
  type        = string
}
variable "create_role" {
  description = "If true, create IAM role and attach minimal policies"
  type        = bool
  default     = true
}

variable "role_name" {
  description = "IAM role name to create (when create_role = true)"
  type        = string
  default     = null
}

variable "role_arn" {
  description = "Existing IAM role ARN (used when create_role = false)"
  type        = string
  default     = null
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "lambda_architecture" {
  description = "Lambda architecture"
  type        = string
  default     = "arm64"
  validation {
    condition     = contains(["arm64", "x86_64"], var.lambda_architecture)
    error_message = "lambda_architecture must be 'arm64' or 'x86_64'."
  }
}

variable "lambda_memory_size" {
  description = "Memory size (in MB) allocated to the Lambda function"
  type        = number
  default     = 128
}

variable "lambda_timeout" {
  description = "Timeout (in seconds) for the Lambda function"
  type        = number
  default     = 10
}

variable "lambda_schedule_expression" {
  description = "EventBridge schedule expression for Lambda (set null to disable scheduling)"
  type        = string
  default     = "rate(15 minutes)"
}

variable "lambda_log_retention_days" {
  description = "CloudWatch Logs retention days"
  type        = number
  default     = 14
}

variable "lambda_environment" {
  description = "Extra environment variables for the Lambda"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Resource tags applied to all resources in this module"
  type        = map(string)
  default     = {}
}
