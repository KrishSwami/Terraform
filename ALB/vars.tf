variable "region" {
  type = string
  default = "ap-southeast-1"
}

variable "def_tag" {
    type = map
    default = {
        "Name" = "vpc_singa"
    }
}

variable "zones" {
    type = list
    default = ["ap-southeast-1a","ap-southeast-1b"]  
}