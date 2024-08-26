# output "webServer1PublicIp" {
#   value = aws_instance.webServer1.public_ip
# }

# output "webServer2PublicIp" {
#   value = aws_instance.webServer2.public_ip
# }
# output "webServer3PublicIp" {
#   value = aws_instance.webServer3.public_ip
# }

# output "webServer4PublicIp" {
#   value = aws_instance.webServer4.public_ip
# }
# output "webServer5PublicIp" {
#   value = aws_instance.webServer5.public_ip
# }

# output "webServer6PublicIp" {
#   value = aws_instance.vm6.public_ip
# }

output "webServerPublicIps" {
  value = {
    for name, instance in aws_instance.web_servers : name => instance.public_ip
    if instance.associate_public_ip_address == true
  }
}