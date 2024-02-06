resource "local_file" "state" {
  filename = "/root/${var.local-state}"
  content  = "This configuration uses ${var.local-state} state"
}