output "minecraft_server_ip" {
  description = "Public IP of the Minecraft server"
  value       = aws_eip.minecraft.public_ip
}