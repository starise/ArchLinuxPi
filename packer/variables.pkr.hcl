#  "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

variable "timezone" {
    type = string
    description = "Server timezone"
    default = "Etc/UTC"
}
