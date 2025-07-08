variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  default = "10.0.2.0/24"
}

variable "subnet_availability_zone" {
  type    = string
  default = "us-west-2a"
}

variable "webapp_ami_id" {
  type    = string
  default = ""
}

variable "mysql_ami_id" {
  type    = string
  default = ""
}

variable "database_username" {
  type    = string
  default = ""
}

variable "database_password" {
  type    = string
  default = ""
}

variable "webapp_secret_key" {
  type    = string
  default = ""
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}