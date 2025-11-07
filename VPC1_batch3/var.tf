variable "vpc_cidr" {
  type = string
}
variable "tag1" {
  type = string
}
variable "vpc_public_cidr" {
  type = string
}
variable "vpc_private_cidr" {
  type = string
}
variable "vpc_private_tag" {
  type = string
}
variable "vpc_public_tag" {
  type = string
}
variable "vpc_igw_tag" {
  type = string
}
variable "ami" {
  type = string
}
variable "i-type" {
  type = string
}
variable "api-termn" {
  type = bool
}
variable "role" {
  type = string
}
variable "key" {
  type = string
}
variable "myip" {
  description = "Your public IP in CIDR format (used to allow SSH to the public instance)"
  type        = string
  default     = "0.0.0.0/0" # ⚠️ Change this to your actual IP, e.g. "203.0.113.25/32"
}
