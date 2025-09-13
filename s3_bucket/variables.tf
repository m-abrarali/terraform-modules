variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "versioning" {
  description = "Enable versioning on the bucket"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Whether to allow bucket to be destroyed with objects inside"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the bucket"
  type = list(object({
    id              = string
    status          = string
    transition_days = number
    storage_class   = string
    prefix          = optional(string)
  }))
  default = []
}
