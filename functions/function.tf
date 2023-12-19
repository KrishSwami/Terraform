output "print" {
    value = "${join("--->",var.users)}"  
}

output "upper" {
    value = "${upper(var.users[0])}"
}

output "title" {
    value = "${title(var.users[1])}"
  
}