variable "user" {
    type = list  
}
output "name" {
    value = "Selected user from the list is ${var.user[2]}"  
}