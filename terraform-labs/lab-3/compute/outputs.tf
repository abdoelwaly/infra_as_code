output "private_key_path" {
  description = "Path to the private key file"
  value       = local_file.private_key.filename
}