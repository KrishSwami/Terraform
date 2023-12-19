variable "username" {
    default = "Krishna"
  }
variable "age" {  
}

output "output" {

    value = "Hello ${var.username} your age is ${var.age}"
  
}