output "instance_public_id" {
  value = [for vm in aws_instance.instance_public : vm.id]
}
# output "instance_private_id"{   
#     value=[for vm in aws_instance.instance_private : vm.id]
# }
