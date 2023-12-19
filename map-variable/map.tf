variable "userage" {
    type = map
    default = {
        krish = 30
        manish = 50
        suresh = 45
    }  
}

variable "username" {
    type = string
  
}
output "userage" {
    value = "my name is ${var.username} and my age is ${lookup(var.userage, "${var.username}")} "
  
}