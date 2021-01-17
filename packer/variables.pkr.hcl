#  "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

variable "timezone" {
    type = string
    description = "Server timezone"
    default = "Etc/UTC"
}

variable "keymap" {
    type = string
    description = "Persistent keyboard layout"
    default = "us"
}

variable "locale" {
    type = string
    description = "Current locale"
    default = "en_US.UTF-8"
}
